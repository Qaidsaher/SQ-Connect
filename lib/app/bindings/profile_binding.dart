// profile_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/profile/edit_profile_controller.dart';
import 'package:sq_connect/app/modules/profile/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ProfileController>(
    //   () => ProfileController(
    //     userRepository: Get.find(),
    //     authController: Get.find(),
    //     userId:
    //         Get.arguments != null && Get.arguments['userId'] != null
    //             ? Get.arguments['userId']
    //             : Get.find<AuthController>()
    //                 .currentUser
    //                 .value
    //                 ?.id, // Default to logged-in user
    //   ),
    // );
    Get.lazyPut<ProfileController>(() {
      print(
        "ProfileBinding: dependencies() called. About to lazyPut ProfileController.",
      );

      final authController =
          Get.find<
            AuthController
          >(); // Assumes AuthController is already put (e.g., in InitialBinding)
      final userRepository =
          Get.find<
            UserRepository
          >(); // Assumes UserRepository is already put (e.g., in InitialBinding)

      int? targetUserId;
      if (Get.arguments != null && Get.arguments['userId'] != null) {
        targetUserId = Get.arguments['userId'] as int?;
      } else if (authController.isAuthenticated.value) {
        targetUserId = authController.currentUser.value?.id;
      }

      print(
        "ProfileBinding: Creating ProfileController for userId: $targetUserId",
      ); // DEBUG LINE

      return ProfileController(
        userRepository: userRepository,
        authController: authController,
        userId: targetUserId,
      );
    });

    Get.lazyPut<EditProfileController>(
      () => EditProfileController(
        userRepository: Get.find(),
        authController: Get.find(),
      ),
      fenix:
          true, // Keep it alive if user navigates back and forth during editing
    );
  }
}
