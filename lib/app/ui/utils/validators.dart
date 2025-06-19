// validators.dart
import 'package:get/get.dart'; // For GetUtils.isEmail

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty.';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long.';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain spaces.';
    }
    // Add more specific username validation if needed (e.g., regex for allowed characters)
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty.';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    // Add more password strength checks (e.g., uppercase, number, special character)
    // Example:
    // if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
    //   return 'Password must contain letters and numbers.';
    // }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }
}