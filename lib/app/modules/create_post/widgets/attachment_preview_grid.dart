import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AttachmentPreviewGrid extends StatelessWidget {
  final List<XFile> attachments;
  final Function(XFile) onRemoveAttachment;

  const AttachmentPreviewGrid({
    super.key,
    required this.attachments,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no attachments
    }

    return GridView.builder(
      shrinkWrap: true, // Important inside SingleChildScrollView or Column
      physics: const NeverScrollableScrollPhysics(), // If inside another scroll view
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1, // Square items
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final file = attachments[index];
        // For now, assuming all are images. Extend for video thumbnails etc.
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(file.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => onRemoveAttachment(file),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
            // TODO: If it's a video, show a play icon overlay
            // if (file.mimeType?.startsWith('video/') ?? false)
            //   Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 40),
          ],
        );
      },
    );
  }
}