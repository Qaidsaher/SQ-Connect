import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sq_connect/app/config/app_colors.dart';
import 'package:sq_connect/app/data/models/attachment_model.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart' as dio_package; // For downloading
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart'; // If using inline PDF view

class PostAttachmentsWidget extends StatefulWidget {
  final List<Attachment> attachments;
  final bool isFullScreenView; // To adapt layout for full screen post detail

  const PostAttachmentsWidget({
    super.key,
    required this.attachments,
    this.isFullScreenView = false,
  });

  @override
  State<PostAttachmentsWidget> createState() => _PostAttachmentsWidgetState();
}

class _PostAttachmentsWidgetState extends State<PostAttachmentsWidget> {
  VideoPlayerController? _videoController;
  String? _currentlyPlayingVideoUrl;
  bool _isVideoInitialized = false;
  bool _isDownloading = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(String videoUrl) {
    if (_currentlyPlayingVideoUrl == videoUrl && _videoController != null) {
      // Already initialized or initializing for this video
      if (!_videoController!.value.isPlaying && _isVideoInitialized) {
        _videoController!.play();
      }
      return;
    }

    _videoController?.dispose(); // Dispose previous controller
    _isVideoInitialized = false;
    _currentlyPlayingVideoUrl = videoUrl;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController!.play();
        _videoController!.setLooping(true);
      }).catchError((error) {
        print("Video player error: $error");
        UIHelpers.showErrorSnackbar("Could not play video.");
        setState(() {
          _currentlyPlayingVideoUrl = null; // Reset
        });
      });
    setState(() {}); // To show loading indicator for video
  }

  Future<void> _openFile(Attachment attachment) async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${attachment.fileType ?? attachment.id.toString()}.${attachment.fileType?.split('/').last ?? 'file'}';
      
      // Using dio for download with progress if needed later
      await dio_package.Dio().download(
        attachment.fileUrlResolved ?? attachment.filePath, // Ensure you have a resolved URL
        filePath,
        onReceiveProgress: (received, total) {
          // You can update a download progress indicator here
        },
      );

      // final OpenResult result = await OpenFile.open(filePath);
      // if (result.type != ResultType.done) {
      //   UIHelpers.showErrorSnackbar('Could not open file: ${result.message}');
      // }
    } catch (e) {
      UIHelpers.showErrorSnackbar('Failed to download or open file: ${e.toString()}');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }


  Widget _buildAttachmentItem(BuildContext context, Attachment attachment, int totalAttachments) {
    final String fileType = attachment.fileType?.toLowerCase() ?? "";
    final String fileUrl = attachment.fileUrlResolved ?? attachment.filePath; // Ensure you have this

    // IMAGE
    if (fileType.startsWith('image')) {
      return GestureDetector(
        onTap: () {
          // TODO: Implement full-screen image viewer
          Get.dialog(Dialog(child: CachedNetworkImage(imageUrl: fileUrl, fit: BoxFit.contain)));
        },
        child: CachedNetworkImage(
          imageUrl: fileUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
        ),
      );
    }
    // VIDEO
    else if (fileType.startsWith('video')) {
      bool isCurrentVideo = _currentlyPlayingVideoUrl == fileUrl;
      return GestureDetector(
        onTap: () => _initializeVideoPlayer(fileUrl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isCurrentVideo && _videoController != null && _isVideoInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            else if (attachment.filePath != null) // Display server-generated thumbnail
              CachedNetworkImage(
                imageUrl: attachment.filePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity),
                 errorWidget: (context, url, error) => Container(color: Colors.black, child: const Icon(FontAwesomeIcons.video, color: Colors.white54, size: 40)),
              )
            else // Fallback if no thumbnail
              Container(color: Colors.black, child: const Icon(FontAwesomeIcons.video, color: Colors.white54, size: 40)),

            if (!isCurrentVideo || (isCurrentVideo && _videoController != null && !_videoController!.value.isPlaying && _isVideoInitialized))
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50),
              ),
            if (isCurrentVideo && _videoController != null && !_isVideoInitialized)
              const LoadingIndicator(color: Colors.white, size: 30), // Loading this specific video
          ],
        ),
      );
    }
    // PDF
    else if (fileType == 'application/pdf') {
      return GestureDetector(
        onTap: () => _openFile(attachment), // Or use flutter_pdfview for inline
        child: Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.filePdf, size: 40, color: AppColors.error),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(attachment.fileType ?? 'View PDF', style: Get.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              if (_isDownloading) const Padding(padding: EdgeInsets.only(top: 8.0), child: LoadingIndicator(size: 20)),
            ],
          ),
        ),
      );
    }
    // DOCX
    else if (fileType == 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' || fileType == 'application/msword') {
       return GestureDetector(
        onTap: () => _openFile(attachment),
        child: Container(
          color: Colors.blue[50],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.fileWord, size: 40, color: Colors.blue[700]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(attachment.fileType ?? 'View Document', style: Get.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              if (_isDownloading) const Padding(padding: EdgeInsets.only(top: 8.0), child: LoadingIndicator(size: 20)),
            ],
          ),
        ),
      );
    }
    // OTHER FILE TYPES
    else {
      return GestureDetector(
        onTap: () => _openFile(attachment),
        child: Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.fileLines, size: 40, color: AppColors.darkGrey),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(attachment.fileType ?? 'Open File', style: Get.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
               if (_isDownloading) const Padding(padding: EdgeInsets.only(top: 8.0), child: LoadingIndicator(size: 20)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachments.isEmpty) return const SizedBox.shrink();

    final int totalAttachments = widget.attachments.length;

    if (totalAttachments == 1) {
      return AspectRatio(
        // Adjust aspect ratio based on content if possible, or use a default
        aspectRatio: (widget.attachments.first.fileType?.startsWith('video') == true && _videoController != null && _isVideoInitialized)
            ? _videoController!.value.aspectRatio
            : 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isFullScreenView ? 0 : 12.0),
          child: _buildAttachmentItem(context, widget.attachments.first, totalAttachments),
        ),
      );
    }

    // Grid for multiple attachments
    double childAspectRatio = 1.0; // Square for 3+ items
    int crossAxisCount = 2;
    if (totalAttachments == 2) childAspectRatio = 16/10; // Wider for 2 items side-by-side
    if (totalAttachments >= 5 && !widget.isFullScreenView) crossAxisCount = 3; // Tighter grid for many items in feed


    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.isFullScreenView ? totalAttachments : (totalAttachments > 4 ? 4 : totalAttachments),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        if (index == 3 && totalAttachments > 4 && !widget.isFullScreenView) {
          // "More" overlay for the 4th item if there are more than 4 attachments
          return GestureDetector(
            onTap: () {
              // TODO: Navigate to a gallery view or expand to show all
              Get.toNamed(Routes.POST_DETAIL, arguments: {'postId': widget.attachments.first.postId, 'scrollToAttachments': true});
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: _buildAttachmentItem(context, widget.attachments[index], totalAttachments)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "+${totalAttachments - 3}",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: _buildAttachmentItem(context, widget.attachments[index], totalAttachments),
        );
      },
    );
  }
}