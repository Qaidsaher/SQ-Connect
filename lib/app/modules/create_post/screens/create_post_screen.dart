import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/modules/create_post/create_post_controller.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For CachedNetworkImageProvider

class CreatePostScreen extends GetView<CreatePostController> {
  CreatePostScreen({super.key});
  final _textController = TextEditingController();
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    _textController.addListener(() {
      controller.content.value = _textController.text;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        // leading: IconButton(
        //   icon: const Icon(Icons.close),
        //   onPressed: () => Get.back(),
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(
              () => InkWell(
                onTap:
                    controller.isLoading.value ||
                            (controller.content.value.trim().isEmpty &&
                                controller.attachments.isEmpty)
                        ? null
                        : controller.submitPost,
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: AppColors.primary,
                //   foregroundColor: Colors.white,
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                // ),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'Post',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            _authController.currentUser.value?.avatarUrl != null
                                ? CachedNetworkImageProvider(
                                  _authController.currentUser.value!.avatarUrl!,
                                )
                                : null,
                        child:
                            _authController.currentUser.value?.avatarUrl == null
                                ? Text(
                                  UIHelpers.getInitials(
                                    _authController.currentUser.value?.name ??
                                        "U",
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration.collapsed(
                            hintText: "What's on your mind?",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                            ),
                          ).copyWith(contentPadding: EdgeInsets.all(12)),
                          style: const TextStyle(fontSize: 18, height: 1.4),
                          minLines: 3,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          maxLength: 1000,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAttachmentPreviewGrid(),
                ],
              ),
            ),
          ),
          _buildAttachmentToolbar(context),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreviewGrid() {
    return Obx(() {
      if (controller.attachments.isEmpty) {
        return const SizedBox.shrink();
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Adjust based on screen size if needed
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.attachments.length,
        itemBuilder: (context, index) {
          final pickedAttachment = controller.attachments[index];
          return Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child:
                    pickedAttachment.thumbnail !=
                            null // For videos with generated thumbnails
                        ? Image.file(
                          pickedAttachment.thumbnail!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : (pickedAttachment.mimeType?.startsWith('image/') ==
                                true
                            ? Image.file(
                              pickedAttachment.file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                            : Container(
                              // Placeholder for other file types
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(
                                _getIconForMimeType(pickedAttachment.mimeType),
                                size: 30,
                                color: Colors.grey[700],
                              ),
                            )),
              ),
              if (pickedAttachment.mimeType?.startsWith('video/') == true)
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 40,
                ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => controller.removeAttachment(pickedAttachment),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  IconData _getIconForMimeType(String? mimeType) {
    if (mimeType == null) return FontAwesomeIcons.file;
    if (mimeType.startsWith('image')) return FontAwesomeIcons.image;
    if (mimeType.startsWith('video')) return FontAwesomeIcons.video;
    if (mimeType == 'application/pdf') return FontAwesomeIcons.filePdf;
    if (mimeType.contains('word')) return FontAwesomeIcons.fileWord;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet'))
      return FontAwesomeIcons.fileExcel;
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint'))
      return FontAwesomeIcons.filePowerpoint;
    if (mimeType.startsWith('audio')) return FontAwesomeIcons.fileAudio;
    return FontAwesomeIcons.fileLines; // Default
  }

  Widget _buildAttachmentToolbar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom > 0
                ? 8
                : MediaQuery.of(context).padding.bottom + 8,
        top: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color:
            Theme.of(context).bottomAppBarTheme.color ??
            Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _toolbarButton(
            context,
            icon: FontAwesomeIcons.images,
            label: "Media",
            onTap: controller.pickMedia,
          ),
          _toolbarButton(
            context,
            icon: FontAwesomeIcons.fileLines,
            label: "Document",
            onTap: controller.pickDocuments,
          ),
          _toolbarButton(
            context,
            icon: FontAwesomeIcons.mapPin,
            label: "Location",
            onTap: () => UIHelpers.showInfoSnackbar("WIP: Location"),
          ),
          _toolbarButton(
            context,
            icon: FontAwesomeIcons.squarePollVertical,
            label: "Poll",
            onTap: () => UIHelpers.showInfoSnackbar("WIP: Polls"),
          ),
        ],
      ),
    );
  }

  Widget _toolbarButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: FaIcon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22,
      ),
      tooltip: label,
      onPressed: onTap,
      splashRadius: 24,
    );
  }
}
