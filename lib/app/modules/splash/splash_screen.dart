import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/splash/splash_controller.dart'; // Create this
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller will handle navigation in its onReady or onInit
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Logo
            FlutterLogo(size: 100),
            Text(
              "Saher Connect",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
