import 'package:get/get.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart'; // Your project name
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/profile/edit_profile_controller.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    // EditProfileController is specific to the authenticated user.
    // It relies on AuthController to get the current user's data.
    Get.lazyPut<EditProfileController>(
      () => EditProfileController(
        userRepository: Get.find<UserRepository>(),
        authController: Get.find<AuthController>(),
      ),
      fenix: true, // Good to use fenix: true for edit screens,
                   // so if the user navigates away and back, the controller
                   // (and potentially unsaved changes if not handled) can be re-initialized
                   // or persist if designed that way.
    );
  }
}