// helpers.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Add url_launcher: ^6.2.5 to pubspec.yaml

class UIHelpers {
  // Snackbar for success
  static void showSuccessSnackbar(String message, {String title = "Success"}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[700],
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  // Snackbar for error
  static void showErrorSnackbar(String message, {String title = "Error"}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // Snackbar for information
  static void showInfoSnackbar(String message, {String title = "Info"}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue[700],
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  // Format date to a readable string (e.g., "Dec 25, 2023" or "Today, 10:00 AM")
  static String formatTimestamp(DateTime timestamp, {bool showTime = true, bool relative = true}) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (relative) {
      if (difference.inSeconds < 5) {
        return 'just now';
      } else if (difference.inMinutes < 1) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24 && timestamp.day == now.day) {
        return 'Today, ${DateFormat.jm().format(timestamp.toLocal())}';
      } else if (difference.inHours < 48 && timestamp.day == now.subtract(const Duration(days: 1)).day) {
         return 'Yesterday, ${DateFormat.jm().format(timestamp.toLocal())}';
      }
    }

    if (timestamp.year == now.year) {
      return DateFormat(showTime ? 'MMM d, hh:mm a' : 'MMM d').format(timestamp.toLocal());
    } else {
      return DateFormat(showTime ? 'MMM d, yyyy, hh:mm a' : 'MMM d, yyyy').format(timestamp.toLocal());
    }
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      showErrorSnackbar('Could not launch $url');
    }
  }

  // Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Get initials from a name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    } else if (words.length > 1) {
      return (words[0].isNotEmpty ? words[0][0].toUpperCase() : '') +
             (words.last.isNotEmpty ? words.last[0].toUpperCase() : '');
    }
    return '?';
  }
  
}