// initial_binding.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';
import 'package:sq_connect/app/data/providers/dio_client.dart';
import 'package:sq_connect/app/data/repositories/auth_repository.dart';
import 'package:sq_connect/app/data/repositories/message_repository.dart';
import 'package:sq_connect/app/data/repositories/post_repository.dart';
import 'package:sq_connect/app/data/repositories/user_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/profile/profile_controller.dart';
import 'package:sq_connect/app/modules/search/search_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.lazyPut<SharedPreferences>(() => sharedPreferences, fenix: true);

    // HTTP Client
    Get.lazyPut<Dio>(() => Dio(), fenix: true);
    Get.lazyPut<DioClient>(() => DioClient(Get.find()), fenix: true);

    // API Provider
    Get.lazyPut<ApiProvider>(() => ApiProvider(Get.find()), fenix: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    // Get.put<SplashController>(SplashController());

    Get.lazyPut<PostRepository>(() => PostRepository(Get.find()), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(Get.find()), fenix: true);
    Get.lazyPut<MessageRepository>(
      () => MessageRepository(Get.find()),
      fenix: true,
    );
    Get.lazyPut<SearchUserController>(
      () => SearchUserController(
        userRepository: Get.find<UserRepository>(),
        postRepository: Get.find<PostRepository>(),
      ),
    );

    Get.put<AuthController>(
      AuthController(Get.find(), Get.find()),
      permanent: true,
    );

    // Controller for the Profile tab (showing the authenticated user's profile)
    // This instance will be used when ProfileScreen (for the auth'd user) is displayed as part of HomeScreen.
    // Get.lazyPut<ProfileController>(() {
    //   final authCtrl = Get.find<AuthController>();
    
    //   return ProfileController(
    //     userRepository: Get.find<UserRepository>(),
    //     authController: authCtrl,
    //     userId:
    //         authCtrl
    //             .currentUser
    //             .value
    //             ?.id, // Explicitly for the authenticated user
    //   );
    // });
  }
}
