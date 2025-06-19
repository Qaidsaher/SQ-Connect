import 'package:get/get.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart'; // Or a dedicated SearchRepository
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/search/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchUserController>(
      () => SearchUserController(
        userRepository: Get.find<UserRepository>(),
        postRepository: Get.find<PostRepository>(),
      ),
    );
  }
}
