// post_detail_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/post_detail/post_detail_controller.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailController>(
      () => PostDetailController(Get.find(), Get.arguments['postId']),
    );
  }
}