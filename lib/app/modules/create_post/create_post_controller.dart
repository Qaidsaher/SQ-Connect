import 'dart:io';
import 'package:dio/dio.dart' as dio_package;
import 'package:file_picker/file_picker.dart'; // Using file_picker for more flexibility
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart'; // Can still use for quick image/video access
import 'package:sq_connect/app/data/repositories/post_repository.dart';
import 'package:sq_connect/app/modules/feed/feed_controller.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // For video thumbnails
import 'package:path_provider/path_provider.dart';    // For storing thumbnails

class PickedAttachment {
  final File file;
  final FileType type;
  final String? fileName;
  final String? mimeType;
  File? thumbnail; // For videos

  PickedAttachment({
    required this.file,
    required this.type,
    this.fileName,
    this.mimeType,
    this.thumbnail,
  });
}

class CreatePostController extends GetxController {
  final PostRepository _postRepository;
  CreatePostController(this._postRepository);

  final RxString content = ''.obs;
  // final RxList<XFile> attachments = <XFile>[].obs; // Old way with image_picker
  final RxList<PickedAttachment> attachments = <PickedAttachment>[].obs;
  final RxBool isLoading = false.obs;
  // final ImagePicker _picker = ImagePicker(); // If still using for quick actions

  // Pick images or videos using file_picker
  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi', 'mkv'], // Common media
      allowMultiple: true,
    );

    if (result != null) {
      for (var platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          File? thumb;
          String mimeType = platformFile.extension?.toLowerCase() ?? '';
          if (['mp4', 'mov', 'avi', 'mkv'].contains(mimeType)) {
             mimeType = 'video/$mimeType'; // Approximate MIME
             thumb = await _generateVideoThumbnail(file.path);
          } else if (['jpg', 'jpeg', 'png', 'gif'].contains(mimeType)) {
             mimeType = 'image/$mimeType'; // Approximate MIME
          }

          attachments.add(PickedAttachment(
            file: file,
            type: FileType.media, // General media
            fileName: platformFile.name,
            mimeType: mimeType,
            thumbnail: thumb,
          ));
        }
      }
    }
  }

  // Pick documents (PDF, DOCX)
  Future<void> pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'], // Add more as needed
      allowMultiple: true,
    );

    if (result != null) {
      for (var platformFile in result.files) {
        if (platformFile.path != null) {
           String mimeType = platformFile.extension?.toLowerCase() ?? '';
            if (mimeType == 'pdf') mimeType = 'application/pdf';
            if (mimeType == 'docx') mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            if (mimeType == 'doc') mimeType = 'application/msword';

          attachments.add(PickedAttachment(
            file: File(platformFile.path!),
            type: FileType.any, // Or be more specific based on extension
            fileName: platformFile.name,
            mimeType: mimeType,
          ));
        }
      }
    }
  }

  Future<File?> _generateVideoThumbnail(String videoPath) async {
    try {
      final String? thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.WEBP, // WEBP is efficient
        maxWidth: 150, // Low resolution for preview
        quality: 25,
      );
      return thumbnailPath != null ? File(thumbnailPath) : null;
    } catch (e) {
      print("Error generating video thumbnail: $e");
      return null;
    }
  }


  void removeAttachment(PickedAttachment attachment) {
    attachments.remove(attachment);
  }

  Future<void> submitPost() async {
    if (content.value.trim().isEmpty && attachments.isEmpty) {
      UIHelpers.showErrorSnackbar("Cannot create an empty post.");
      return;
    }
    isLoading.value = true;
    try {
      List<dio_package.MultipartFile> fileParts = [];
      for (var pickedFile in attachments) {
        fileParts.add(await dio_package.MultipartFile.fromFile(
          pickedFile.file.path,
          filename: pickedFile.fileName ?? pickedFile.file.path.split('/').last,
          // contentType: pickedFile.mimeType != null ? MediaType.parse(pickedFile.mimeType!) : null, // Dio handles this
        ));
      }

      final response = await _postRepository.createPost(content.value.trim(), attachments: fileParts);
      if (response.success) {
        Get.back();
        UIHelpers.showSuccessSnackbar("Post created successfully!");
        if (Get.isRegistered<FeedController>()) {
          Get.find<FeedController>().fetchPosts(refresh: true);
        }
      } else {
        String errorMessage = response.message;
        if (response.errors != null && response.errors!.isNotEmpty) {
          errorMessage += "\n" + response.errors!.entries.map((e) => (e.value as List).join(", ")).join("\n");
        }
        UIHelpers.showErrorSnackbar(errorMessage, title: "Post Creation Failed");
      }
    } catch (e) {
      UIHelpers.showErrorSnackbar("An unexpected error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}