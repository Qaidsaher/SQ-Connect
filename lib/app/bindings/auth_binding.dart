// auth_binding.dart

import 'package:get/get.dart';
// AuthController is already globally put by InitialBinding
// No need to put it again here unless it was not permanent or you need a specific instance
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // If AuthController wasn't permanent in InitialBinding, you'd put it here:
    // Get.lazyPut<AuthController>(() => AuthController(Get.find(), Get.find()));
  }
}