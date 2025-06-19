import 'package:sq_connect/app/data/models/attachment_model.dart';
import 'package:sq_connect/app/data/models/comment_model.dart'; // If you want to nest first few comments
import 'package:sq_connect/app/data/models/user_model.dart';

class Post {
  final int id;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships (should be populated by API response)
  final User user;
  final List<Attachment>? attachments;
  final List<Comment>? // For direct embedding of a few top comments
  sampleComments;

  // Aggregates & States (should be populated by API response or calculated)
  final int commentsCount;
  final int likesCount;
  final bool isLiked; // By the authenticated user

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    this.attachments,
    this.sampleComments,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    User parsedUser;
    if (json['user'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['user'] as Map<String, dynamic>);
    } else {
      // Fallback or error, essential for PostCard
      print("Warning: Post ${json['id']} has missing or malformed user data.");
      parsedUser = User(
        id: json['user_id'] ?? 0,
        name: "Unknown User",
        email: '',
        username: "unknown",
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: parsedUser,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((item) => Attachment.fromJson(item as Map<String, dynamic>))
              .toList(),
      sampleComments:
          (json['comments']
                  as List<dynamic>?) // If API provides sample comments
              ?.map((item) => Comment.fromJson(item as Map<String, dynamic>))
              .toList(),
      commentsCount: json['comments_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false, // From your Laravel accessor
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'user': user.toJson(),
    'attachments':
        attachments
            ?.map((a) => a.toJson())
            .toList(), // Assuming Attachment has toJson
    'comments_count': commentsCount,
    'likes_count': likesCount,
    'is_liked': isLiked,
  };

  // copyWith method for easy state updates (e.g., after liking)
  Post copyWith({
    int? id,
    int? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    List<Attachment>? attachments,
    List<Comment>? sampleComments,
    int? commentsCount,
    int? likesCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      attachments: attachments ?? this.attachments,
      sampleComments: sampleComments ?? this.sampleComments,
      commentsCount: commentsCount ?? this.commentsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
