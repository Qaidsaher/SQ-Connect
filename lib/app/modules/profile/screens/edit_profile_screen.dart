// edit_profile_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/profile/edit_profile_controller.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  EditProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(
            () =>
                controller.isLoading.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingIndicator(size: 20),
                    )
                    : TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!
                              .save(); // Triggers onSaved for TextFormFields
                          controller.saveProfile();
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.editableUser.value == null) {
          return const Center(child: LoadingIndicator()); // Or error message
        }
        // Initialize text controllers here if not done in controller, or bind directly
        final nameController = TextEditingController(
          text: controller.name.value,
        );
        final usernameController = TextEditingController(
          text: controller.username.value,
        );
        final emailController = TextEditingController(
          text: controller.email.value,
        );
        final bioController = TextEditingController(text: controller.bio.value);

        nameController.addListener(
          () => controller.name.value = nameController.text,
        );
        usernameController.addListener(
          () => controller.username.value = usernameController.text,
        );
        emailController.addListener(
          () => controller.email.value = emailController.text,
        );
        bioController.addListener(
          () => controller.bio.value = bioController.text,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              controller.newAvatarFile.value != null
                                  ? FileImage(controller.newAvatarFile.value!)
                                  : (controller.editableUser.value?.avatarUrl !=
                                              null
                                          ? CachedNetworkImageProvider(
                                            controller
                                                .editableUser
                                                .value!
                                                .avatarUrl!,
                                          )
                                          : null)
                                      as ImageProvider?,
                          child:
                              controller.newAvatarFile.value == null &&
                                      controller
                                              .editableUser
                                              .value
                                              ?.avatarUrl ==
                                          null
                                  ? Text(
                                    controller
                                                .editableUser
                                                .value
                                                ?.name
                                                .isNotEmpty ??
                                            false
                                        ? controller.editableUser.value!.name[0]
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(fontSize: 50),
                                  )
                                  : null,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Username cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return 'Email cannot be empty';
                    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),
                // TODO: Add "Change Password" button navigating to a new screen
              ],
            ),
          ),
        );
      }),
    );
  }
}
