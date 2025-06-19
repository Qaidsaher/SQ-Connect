import 'package:get/get.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthController _authController =
      Get.find<AuthController>(); // Ensure AuthController is found

  @override
  void onInit() {
    super.onInit();
    print("SPLASH_CONTROLLER: onReady called. Navigating to next screen...");
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    print("SPLASH_CONTROLLER: _navigateToNextScreen - START");
    // This delay can be adjusted or removed if AuthController's _checkLoginStatus is quick
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Increased slightly for visual splash
    // await _authController.initializationCompleter.future; // If using a Completer in AuthController

    print(
      "SPLASH_CONTROLLER: AuthController found. isAuthenticated: ${_authController.isAuthenticated.value}",
    );

    if (_authController.isAuthenticated.value) {
      print("SPLASH_CONTROLLER: Navigating to HOME");
      Get.offAllNamed(Routes.HOME);
    } else {
      print("SPLASH_CONTROLLER: Navigating to LOGIN");
      Get.offAllNamed(Routes.LOGIN);
    }
    print("SPLASH_CONTROLLER: _navigateToNextScreen - END");
  }
}
