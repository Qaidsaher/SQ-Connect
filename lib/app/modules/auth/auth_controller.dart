// auth_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sq_connect/app/config/app_constants.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/repositories/auth_repository.dart';
import 'package:sq_connect/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  AuthController(this._authRepository, this._prefs);

  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString token = ''.obs;
  // ... (existing properties)
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // ... (existing methods)

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoading.value = true; // Good to set loading true here
    print("AUTH_CONTROLLER: _checkLoginStatus - START");
    final storedToken = _prefs.getString(AppConstants.authTokenKey);
    final storedUserJson = _prefs.getString(AppConstants.userDataKey);

    print("AUTH_CONTROLLER: Stored Token: $storedToken");
    print("AUTH_CONTROLLER: Stored User JSON: $storedUserJson");

    if (storedToken != null &&
        storedToken.isNotEmpty &&
        storedUserJson != null) {
      try {
        token.value = storedToken;
        currentUser.value = User.fromJson(jsonDecode(storedUserJson));
        isAuthenticated.value = true;
        print(
          "AUTH_CONTROLLER: User is Authenticated from stored data. isAuthenticated: ${isAuthenticated.value}",
        );
        // Optional: Verify token with a /me request here for added security if desired
        // await fetchCurrentUser(); // Be careful, if this fails it might log out a valid session
      } catch (e) {
        print(
          "AUTH_CONTROLLER: Error parsing stored user data: $e. Clearing stored data.",
        );
        // If parsing fails, clear bad data and treat as unauthenticated
        await _prefs.remove(AppConstants.authTokenKey);
        await _prefs.remove(AppConstants.userDataKey);
        isAuthenticated.value = false;
        print(
          "AUTH_CONTROLLER: User is NOT Authenticated. isAuthenticated: ${isAuthenticated.value}",
        );
      }
    } else {
      isAuthenticated.value = false;
      print(
        "AUTH_CONTROLLER: No valid stored token/user. User is NOT Authenticated. isAuthenticated: ${isAuthenticated.value}",
      );
    }
    isLoading.value = false; // Set loading false after check
    print(
      "AUTH_CONTROLLER: _checkLoginStatus - END. isAuthenticated: ${isAuthenticated.value}",
    );
  }

  Future<void> login(String loginField, String password) async {
    isLoading.value = true;
    try {
      final response = await _authRepository.login(loginField, password);
      if (response.success && response.data != null) {
        final responseData = response.data!;
        final user = User.fromJson(
          responseData['user'] as Map<String, dynamic>,
        );
        final accessToken = responseData['access_token'] as String;

        currentUser.value = user;
        token.value = accessToken;
        isAuthenticated.value = true;

        await _prefs.setString(AppConstants.authTokenKey, accessToken);
        await _prefs.setString(
          AppConstants.userDataKey,
          jsonEncode(user.toJson()),
        );

        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Login Failed',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
    String name,
    String username,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    isLoading.value = true;
    try {
      final response = await _authRepository.register(
        name,
        username,
        email,
        password,
        passwordConfirmation,
      );
      if (response.success && response.data != null) {
        final responseData = response.data!;
        final user = User.fromJson(
          responseData['user'] as Map<String, dynamic>, // This is correct
        );
        final accessToken = responseData['access_token'] as String;

        currentUser.value = user;
        token.value = accessToken;
        isAuthenticated.value = true;

        await _prefs.setString(AppConstants.authTokenKey, accessToken);
        await _prefs.setString(
          AppConstants.userDataKey,
          jsonEncode(user.toJson()),
        );
        Get.offAllNamed(Routes.HOME);
      } else {
        String errorMessage = response.message;
        if (response.errors != null) {
          errorMessage +=
              "\n" +
              response.errors!.entries
                  .map((e) => e.value.join(", "))
                  .join("\n");
        }
        Get.snackbar(
          'Registration Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print(
        'Registration Error' + 'An unexpected error occurred: ${e.toString()}',
      );

      Get.snackbar(
        'Registration Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentUser() async {
    if (!isAuthenticated.value) return;
    isLoading.value = true;
    try {
      final response = await _authRepository.getMe();
      if (response.success && response.data != null) {
        currentUser.value = response.data;
        await _prefs.setString(
          AppConstants.userDataKey,
          jsonEncode(response.data!.toJson()),
        );
      } else {
        // Token might be invalid, logout
        await logout();
      }
    } catch (e) {
      await logout(); // Error fetching user, likely bad token
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      // Optionally call API logout endpoint
      await _authRepository.logout();
    } catch (e) {
      // Handle error, but proceed with local logout
      print("Error calling API logout: $e");
    } finally {
      await _prefs.remove(AppConstants.authTokenKey);
      await _prefs.remove(AppConstants.userDataKey);
      token.value = '';
      currentUser.value = null;
      isAuthenticated.value = false;
      isLoading.value = false;
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
