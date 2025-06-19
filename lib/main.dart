import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/bindings/initial_binding.dart';
import 'package:sq_connect/app/config/app_constants.dart';
import 'package:sq_connect/app/config/app_theme.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/routes/app_pages.dart';
import 'package:sq_connect/app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await InitialBinding().dependencies();
    print("InitialBinding completed successfully.");
  } catch (e, s) {
    print("ERROR in InitialBinding: $e");
    return;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(), // Already called in main
    );
  }
}
