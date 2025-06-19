// comment_model.dart
import 'package:sq_connect/app/data/models/user_model.dart';

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final int? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user; // Eager loaded from API
  final List<Comment>? replies; // Eager loaded from API

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
      parentCommentId: json['parent_comment_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      replies:
          json['replies'] != null
              ? (json['replies'] as List)
                  .map((i) => Comment.fromJson(i as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }
}
