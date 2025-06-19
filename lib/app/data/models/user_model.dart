import 'package:sq_connect/app/config/app_constants.dart'; // Your project name

class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final String? avatar; // This should ideally be the server-provided path or full URL
  final String role;    // Changed to non-nullable with a default
  final String? bio;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? followersCount;
  final int? followingCount;
  final bool? isFollowedByAuthUser;

  // accessToken is typically part of the Auth response, not the User object itself from most API endpoints.
  // If your API returns it with every user object, you can keep it. Otherwise, consider removing it from here.
  final String? accessToken; // Keeping it for now based on your original code

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.avatar,
    required this.role, // role is now required in constructor
    this.bio,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.accessToken,
    this.followersCount,
    this.followingCount,
    this.isFollowedByAuthUser,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Print for debugging what JSON User.fromJson receives
    // print("User.fromJson input: $json");

    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      // Prefer 'avatar_url' if your Laravel accessor provides it, otherwise use 'avatar'
      avatar: json['avatar_url'] as String? ?? json['avatar'] as String?,
      role: json['role'] as String? ?? 'user', // Default to 'user' if null or missing
      bio: json['bio'] as String?, // Bio can be null
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // accessToken is typically not part of this nested user object in API responses
      // It's usually at the top level of a login/register response.
      // If your /api/users/{id} or /api/me also includes it, then it's fine.
      accessToken: json['access_token'] as String?,
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
      isFollowedByAuthUser: json['is_followed_by_auth_user'] as bool?,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? username,
    String? avatar,
    String? role,
    String? bio, // Nullable bio
    DateTime? emailVerifiedAt, // Nullable
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken, // Nullable accessToken
    int? followersCount,
    int? followingCount,
    bool? isFollowedByAuthUser,
  }) {
    return User(
      id: id ?? this.id, // Corrected: was 'id  this.id'
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      bio: bio ?? this.bio, // Allow bio to be explicitly set to null if needed or keep old
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowedByAuthUser: isFollowedByAuthUser ?? this.isFollowedByAuthUser,
    );
  }

  Map<String, dynamic> toJson() {
    // Only include non-null values for cleaner JSON, especially for PATCH requests
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (avatar != null) data['avatar'] = avatar;
    if (bio != null) data['bio'] = bio;
    if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt!.toIso8601String();
    if (accessToken != null) data['access_token'] = accessToken; // Only if relevant to serialize
    if (followersCount != null) data['followers_count'] = followersCount;
    if (followingCount != null) data['following_count'] = followingCount;
    if (isFollowedByAuthUser != null) data['is_followed_by_auth_user'] = isFollowedByAuthUser;
    return data;
  }

  // Helper to get full avatar URL
  // This assumes `avatar` field stores the relative path like 'avatars/image.png'
  // And your Laravel User model might have an accessor `getAvatarUrlAttribute`
  // that returns the full URL. If API sends full URL, this getter might not be strictly needed here.
  String? get avatarUrl {
    if (avatar == null || avatar!.isEmpty) return null;
    if (avatar!.startsWith('http://') || avatar!.startsWith('https://')) {
      return avatar; // It's already a full URL
    }
    // If it's a relative path from Laravel storage (e.g., "avatars/filename.jpg")
    // and your API base URL is configured correctly, and you have a public storage disk linked.
    // Ensure AppConstants.apiBaseUrl does not end with '/api' for this construction.
    final baseUrl = AppConstants.apiBaseUrl.endsWith('/api')
        ? AppConstants.apiBaseUrl.substring(0, AppConstants.apiBaseUrl.length - 4)
        : AppConstants.apiBaseUrl;
    return '$baseUrl/storage/$avatar';
  }
}