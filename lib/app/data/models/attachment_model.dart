import 'package:sq_connect/app/config/app_constants.dart'; // Your project name

class Attachment {
  final int id;
  final int postId;
  final String
  filePath; // Path as stored on the server (e.g., "post_attachments/image.jpg")
  final String? fileType; // MIME type
  final DateTime createdAt;
  final DateTime updatedAt;
  final String?
  fileUrlFromApi; // The file_url directly from the API (from Laravel accessor)

  Attachment({
    required this.id,
    required this.postId,
    required this.filePath,
    this.fileType,
    required this.createdAt,
    required this.updatedAt,
    this.fileUrlFromApi, // Make this nullable to handle cases where it might be missing
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Read file_url from API if present, otherwise it will be null
      fileUrlFromApi: json['file_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'file_path': filePath,
    'file_type': fileType,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'file_url': fileUrlFromApi, // Include the API provided URL if present
  };

  /// Getter to reliably get a full, usable URL for the attachment.
  /// It prioritizes the `fileUrlFromApi` (which should be provided by the Laravel accessor).
  /// If that's missing, it attempts to construct the URL from `filePath` and `AppConstants.apiBaseUrl`.
  String? get fileUrlResolved {
    // 1. Prioritize the URL directly provided by the API (from Laravel's Storage::url())
    if (fileUrlFromApi != null && fileUrlFromApi!.isNotEmpty) {
      if (fileUrlFromApi!.startsWith('http://') ||
          fileUrlFromApi!.startsWith('https://')) {
        return fileUrlFromApi;
      }
      // If fileUrlFromApi is relative (less ideal, but handle it)
      // This assumes fileUrlFromApi if relative starts with /storage/
      final baseUrl =
          AppConstants.apiBaseUrl.endsWith('/api')
              ? AppConstants.apiBaseUrl.substring(
                0,
                AppConstants.apiBaseUrl.length - 4,
              )
              : AppConstants.apiBaseUrl;
      if (fileUrlFromApi!.startsWith('/')) {
        return '$baseUrl$fileUrlFromApi';
      }
      return '$baseUrl/$fileUrlFromApi';
    }

    // 2. If fileUrlFromApi is not available, try to construct from filePath
    if (filePath.isEmpty) return null;

    // Check if filePath itself is already a full URL (less common for filePath)
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      return filePath;
    }

    // Construct from filePath assuming it's a relative path like "post_attachments/image.jpg"
    // and needs to be appended to "your_base_url/storage/"
    final baseUrl =
        AppConstants.apiBaseUrl.endsWith('/api')
            ? AppConstants.apiBaseUrl.substring(
              0,
              AppConstants.apiBaseUrl.length - 4,
            )
            : AppConstants.apiBaseUrl;

    // Ensure filePath doesn't accidentally start with a slash if it's meant to be relative to /storage/
    final cleanFilePath =
        filePath.startsWith('/') ? filePath.substring(1) : filePath;

    return '$baseUrl/storage/$cleanFilePath';
  }
}
