// home_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/feed/feed_controller.dart';
import 'package:sq_connect/app/modules/home/home_controller.dart';
import 'package:sq_connect/app/modules/profile/profile_controller.dart';
// Import other controllers for tabs if needed

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    Get.lazyPut<FeedController>(
      () => FeedController(Get.find()),
    ); // Needs PostRepository
    Get.lazyPut<ProfileController>(() {
      final authCtrl = Get.find<AuthController>();
      // This instance is specifically for the authenticated user's profile tab
      return ProfileController(
        userRepository: Get.find<UserRepository>(),
        authController: authCtrl,
        userId: authCtrl.currentUser.value?.id, // Use authenticated user's ID
      );
    }, tag: "authUserProfile"); // Use a tag to differentiate if needed
  }
}
