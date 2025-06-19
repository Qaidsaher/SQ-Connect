// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For Get.back()

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor; // For title and icons
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackButtonPressed,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 1.0, // Subtle elevation by default
  });

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ?? Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onPrimary;

    return AppBar(
      title: Text(title, style: TextStyle(color: effectiveForegroundColor, fontWeight: FontWeight.w500)),
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).primaryColor,
      elevation: elevation,
      leading: leading ?? (showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: effectiveForegroundColor),
              onPressed: onBackButtonPressed ?? () => Get.back(),
            )
          : null),
      actions: actions,
      iconTheme: IconThemeData(color: effectiveForegroundColor), // For actions icons
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Example Usage (replace existing AppBars where appropriate):
// Scaffold(
//   appBar: CustomAppBar(
//     title: 'Profile',
//     actions: [
//       IconButton(icon: Icon(Icons.settings), onPressed: () {})
//     ],
//   ),
//   body: ...
// )