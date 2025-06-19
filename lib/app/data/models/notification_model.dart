import 'package:sq_connect/app/data/models/user_model.dart';

class AppNotification {
  final String id; // UUID from Laravel
  final String type;
  final String action;
  final String? icon;
  final String? color;
  final String? message;
  final String? url;
  final String? extra;
  final int? postId;
  final String? timestamp;

  // Embedded user info
  final int? userId;
  final String? username;
  final User? user; // Optional: if full user object included

  bool read; // runtime-only flag for UI updates

  AppNotification({
    required this.id,
    required this.type,
    required this.action,
    this.icon,
    this.color,
    this.message,
    this.url,
    this.extra,
    this.postId,
    this.timestamp,
    this.userId,
    this.username,
    this.user,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      action: data['action'] ?? '',
      icon: data['icon'],
      color: data['color'],
      message: data['message'],
      url: data['url'],
      extra: data['extra'],
      postId: data['post_id'],
      timestamp: data['timestamp'],
      userId: data['user_id'],
      username: data['username'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      read: json['read_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': {
        'action': action,
        'icon': icon,
        'color': color,
        'message': message,
        'url': url,
        'extra': extra,
        'post_id': postId,
        'timestamp': timestamp,
        'user_id': userId,
        'username': username,
      },
      'read_at': read ? DateTime.now().toIso8601String() : null,
    };
  }

  // For UI-friendly display
  String get formattedTime => timestamp ?? '';
}
