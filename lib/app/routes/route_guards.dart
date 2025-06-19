import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  final authService = Get.find<AuthController>();

  @override
  RouteSettings? redirect(String? route) {
    // If user is not authenticated and trying to access a protected route (not login/register/splash)
    if (!authService.isAuthenticated.value &&
        route != Routes.LOGIN &&
        route != Routes.REGISTER &&
        route != Routes.SPLASH /* add other public routes here */ ) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    // If user IS authenticated and tries to go to LOGIN or REGISTER, redirect to HOME
    else if (authService.isAuthenticated.value &&
        (route == Routes.LOGIN || route == Routes.REGISTER)) {
      return const RouteSettings(name: Routes.HOME);
    }
    return null; // No redirect needed
  }
}
