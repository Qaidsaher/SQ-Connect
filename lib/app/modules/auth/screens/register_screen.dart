// register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_constants.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:sq_connect/app/ui/utils/validators.dart'; // Assuming you have validators

class RegisterScreen extends GetView<AuthController> {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent, // Or Theme.of(context).scaffoldBackgroundColor
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color, // Icon color
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Join '+AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to connect and share.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                _buildTextFormField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocusNode: _usernameFocus,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  nextFocusNode: _emailFocus,
                  labelText: 'Username',
                  hintText: 'Choose a unique username',
                  icon: Icons.alternate_email_outlined,
                  validator: Validators.validateUsername,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                Obx(() => _buildTextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      nextFocusNode: _confirmPasswordFocus,
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      icon: Icons.lock_outline,
                      obscureText: !controller.isPasswordVisible.value, // Assuming you add this to AuthController
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: controller.togglePasswordVisibility, // Add this method to AuthController
                      ),
                    )),
                const SizedBox(height: 16),
                 Obx(() => _buildTextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      icon: Icons.lock_outline,
                      obscureText: !controller.isConfirmPasswordVisible.value, // Add to AuthController
                      validator: (value) => Validators.validateConfirmPassword(
                          value, _passwordController.text),
                      textInputAction: TextInputAction.done,
                       suffixIcon: IconButton(
                        icon: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility, // Add to AuthController
                      ),
                    )),
                const SizedBox(height: 32),
                Obx(() {
                  return controller.isLoading.value
                      ? const Center(child: LoadingIndicator())
                      : ElevatedButton(
                          onPressed: _submitRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Register', style: TextStyle(fontSize: 16)),
                        );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Get.offNamed(Routes.LOGIN); // Use offNamed to clear register from stack
                      },
                      child: const Text('Login Here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    required String? Function(String?) validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50], // Light background for text fields
      ),
      validator: validator,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(Get.context!).requestFocus(nextFocusNode);
        } else {
          _submitRegister(); // If it's the last field
        }
      },
    );
  }

  void _submitRegister() {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(Get.context!).unfocus();
      controller.register(
        _nameController.text.trim(),
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );
    }
  }
}