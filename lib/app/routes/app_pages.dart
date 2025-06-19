// app_pages.dart

import 'package:get/get.dart';
import 'package:sq_connect/app/bindings/auth_binding.dart';
import 'package:sq_connect/app/bindings/chat_binding.dart';
import 'package:sq_connect/app/bindings/create_post_binding.dart';
import 'package:sq_connect/app/bindings/home_binding.dart';
import 'package:sq_connect/app/bindings/post_detail_binding.dart';
import 'package:sq_connect/app/bindings/profile_binding.dart';
import 'package:sq_connect/app/bindings/search_binding.dart';
import 'package:sq_connect/app/bindings/splash_binding.dart';
import 'package:sq_connect/app/modules/auth/screens/login_screen.dart';
import 'package:sq_connect/app/modules/auth/screens/register_screen.dart';
import 'package:sq_connect/app/modules/chat/screens/chat_screen.dart';
import 'package:sq_connect/app/modules/chat/screens/conversations_screen.dart';
import 'package:sq_connect/app/modules/create_post/screens/create_post_screen.dart';
import 'package:sq_connect/app/modules/home/screens/home_screen.dart';
import 'package:sq_connect/app/modules/post_detail/screens/post_detail_screen.dart';
import 'package:sq_connect/app/modules/profile/screens/edit_profile_screen.dart';
import 'package:sq_connect/app/modules/profile/screens/profile_screen.dart';
import 'package:sq_connect/app/modules/search/screens/search_screen.dart';
import 'package:sq_connect/app/modules/splash/splash_screen.dart';
import 'package:sq_connect/app/routes/route_guards.dart';

// Import other screens and bindings

import 'app_routes.dart';

class AppPages {
  // static const INITIAL = Routes.LOGIN; // Or SPLASH then decide

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
      // middlewares: [AuthGuard()],
    ), // Add Splash Screen
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      middlewares: [AuthGuard()],
      // HomeBinding will also bind FeedController, etc.
    ),

    GetPage(
      name: Routes.SEARCH,
      page: () => SearchScreen(),
      binding: SearchBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.POST_DETAIL,
      page: () => PostDetailScreen(),
      binding: PostDetailBinding(),
    ),
    GetPage(
      name: Routes.CREATE_POST,
      page: () => CreatePostScreen(),
      binding: CreatePostBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () {
        return ProfileScreen();
      },
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
      //
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => EditProfileScreen(),
      binding: ProfileBinding(), // Can reuse or make specific
    ),
    GetPage(
      name: Routes.CONVERSATIONS,
      page: () => const ConversationsScreen(),
      binding: ConversationsBinding(), // Use the new binding
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatScreen(),
      binding: ChatBinding(), // Use the new binding
    ),
    GetPage(
      name: Routes.POST_DETAIL,
      page: () => PostDetailScreen(),
      binding: PostDetailBinding(),
    ),
  ];
}
