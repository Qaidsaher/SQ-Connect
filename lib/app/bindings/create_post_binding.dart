// create_post_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/create_post/create_post_controller.dart';
// PostRepository should be globally available from InitialBinding

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(
      () => CreatePostController(Get.find()), // Get.find() will get the PostRepository
    );
  }
}