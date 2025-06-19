// api_response_model.dart

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? errors; // For validation errors

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String,
      errors: json['errors'] != null ? Map<String, dynamic>.from(json['errors']) : null,
    );
  }
}