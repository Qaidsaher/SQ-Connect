import 'dart:io';

import 'package:dio/dio.dart' as dio_package;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/profile/profile_controller.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepository;
  final AuthController _authController;

  EditProfileController({
    required UserRepository userRepository,
    required AuthController authController,
  }) : _userRepository = userRepository,
       _authController = authController;

  final Rx<User?> editableUser = Rx<User?>(null);
  final Rx<File?> newAvatarFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  late RxString name;
  late RxString username;
  late RxString email;
  late RxString bio;

  @override
  void onInit() {
    super.onInit();
    final currentUser = _authController.currentUser.value;
    if (currentUser != null) {
      editableUser.value = currentUser;
      name = (currentUser.name).obs;
      username = (currentUser.username).obs;
      email = (currentUser.email).obs;
      bio = (currentUser.bio ?? '').obs;
    } else {
      // Handle case where user is not logged in, though ideally this screen shouldn't be reachable
      Get.back(); // or navigate to login
    }
  }

  Future<void> pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      newAvatarFile.value = File(image.path);
    }
  }

  Future<void> saveProfile() async {
    if (editableUser.value == null) return;
    isLoading.value = true;
    errorMessage.value = '';

    Map<String, String> updatedData = {};
    if (name.value != editableUser.value!.name)
      updatedData['name'] = name.value;
    if (username.value != editableUser.value!.username)
      updatedData['username'] = username.value;
    if (email.value != editableUser.value!.email)
      updatedData['email'] = email.value;
    if (bio.value != (editableUser.value!.bio ?? ''))
      updatedData['bio'] = bio.value;

    try {
      // Update text fields first
      if (updatedData.isNotEmpty) {
        final profileResponse = await _userRepository.updateUserProfile(
          updatedData,
        );
        if (profileResponse.success && profileResponse.data != null) {
          _authController.currentUser.value =
              profileResponse.data; // Update global auth controller
          editableUser.value =
              profileResponse.data; // Update local editable user
        } else {
          errorMessage.value = profileResponse.message;
          isLoading.value = false;
          return;
        }
      }

      // Then update avatar if selected
      if (newAvatarFile.value != null) {
        final avatarMultipartFile = await dio_package.MultipartFile.fromFile(
          newAvatarFile.value!.path,
          filename: newAvatarFile.value!.path.split('/').last,
        );
        final avatarResponse = await _userRepository.updateUserAvatar(
          avatarMultipartFile,
        );
        if (avatarResponse.success && avatarResponse.data != null) {
          final newAvatarUrl = avatarResponse.data!['avatar_url'] as String;
          // Assuming backend updates the user record and returns the full user object after avatar update
          // OR we manually update the avatar URL in the currentUser model.
          // For simplicity, let's assume the API updates the user and returns it, or we refetch
          await _authController
              .fetchCurrentUser(); // Refetch to get the latest user with new avatar
          editableUser.value = _authController.currentUser.value;
        } else {
          errorMessage.value +=
              "\nAvatar update failed: ${avatarResponse.message}";
          // Note: profile data might have been saved successfully even if avatar fails.
        }
      }

      if (errorMessage.value.isEmpty) {
        Get.back(); // Go back to profile screen
        Get.snackbar(
          "Success",
          "Profile updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
        );
        // Refresh the ProfileScreen if it's the previous route
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().refreshProfileAndPosts();
        }
      } else {
        Get.snackbar(
          "Error",
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      errorMessage.value = "An error occurred: ${e.toString()}";
      Get.snackbar(
        "Error",
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
