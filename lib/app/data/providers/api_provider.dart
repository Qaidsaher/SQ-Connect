// api_provider.dart

import 'package:dio/dio.dart';
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart'; // Import other models as needed
import 'package:sq_connect/app/data/providers/dio_client.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/models/comment_model.dart';
import 'package:sq_connect/app/data/models/message_model.dart';

class ApiProvider {
  final DioClient _dioClient;

  ApiProvider(this._dioClient);

  // AUTH
  Future<ApiResponse<Map<String, dynamic>>> login(
    String login,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        '/login',
        data: {'login': login, 'password': password},
      );
      // The 'data' from backend contains 'access_token', 'token_type', 'user'
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {'success': false, 'message': e.message ?? 'Login failed'},
        (data) => data != null ? data as Map<String, dynamic> : {},
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
    String name,
    String username,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await _dioClient.post(
        '/register',
        data: {
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {'success': false, 'message': e.message ?? 'Registration failed'},
        (data) => data != null ? data as Map<String, dynamic> : {},
      );
    }
  }

  Future<ApiResponse<User>> getMe() async {
    try {
      final response = await _dioClient.get('/me');
      return ApiResponse.fromJson(
        response.data,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Failed to get user',
        data: null,
      );
    }
  }

  Future<ApiResponse<dynamic>> logout() async {
    // Data might be empty on success
    try {
      final response = await _dioClient.post('/logout');
      return ApiResponse.fromJson(
        response.data,
        (data) => data,
      ); // No specific model for logout data
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {'success': false, 'message': e.message ?? 'Logout failed'},
        (data) => null,
      );
    }
  }

  // POSTS
  Future<ApiResponse<List<Post>>> getPosts({int page = 1}) async {
    try {
      final response = await _dioClient.get(
        '/posts',
        queryParameters: {'page': page},
      );
      // Assuming your API returns paginated data where `response.data['data']['data']` is the list of posts
      // and `response.data['data']` contains pagination info.
      // For simplicity, let's assume the list is directly in `response.data['data']` if not paginated or `response.data['data']['data']` if paginated.
      // Adjust based on your actual API response structure for pagination.
      // This example expects the list of posts to be in `response.data['data']['data']`
      final paginatedData = response.data['data'];
      final List<dynamic> postListJson = paginatedData['data'] as List<dynamic>;
      final posts =
          postListJson
              .map((json) => Post.fromJson(json as Map<String, dynamic>))
              .toList();
      // You might want to return the whole paginated object if you need `last_page`, `current_page`, etc.
      // For now, just returning the list.
      return ApiResponse(success: true, data: posts, message: "Posts fetched");
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to fetch posts',
        data: null,
      );
    }
  }

  Future<ApiResponse<Post>> getPost(int postId) async {
    try {
      final response = await _dioClient.get('/posts/$postId');
      return ApiResponse.fromJson(
        response.data,
        (data) => Post.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message:
            e.response?.data?['message'] ?? e.message ?? 'Failed to get post',
        data: null,
      );
    }
  }

  Future<ApiResponse<Post>> createPost(
    String content, {
    List<MultipartFile>? attachments,
  }) async {
    try {
      FormData formData = FormData.fromMap({'content': content});
      if (attachments != null && attachments.isNotEmpty) {
        for (var file in attachments) {
          formData.files.add(MapEntry('attachments[]', file));
        }
      }
      final response = await _dioClient.post('/posts', data: formData);
      return ApiResponse.fromJson(
        response.data,
        (data) => Post.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<Post>(
        success: false,
        message:
            e.response?.data?['message'] ??
            e.message ??
            'Failed to create post',
        data: null,
      );
    }
  }

  // Add methods for updatePost, deletePost, likePost, unlikePost, addComment, etc.
  // Example for Liking a Post
  Future<ApiResponse<Map<String, dynamic>>> likePost(int postId) async {
    try {
      final response = await _dioClient.post('/posts/$postId/like');
      // Data contains 'like' object and 'likes_count'
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {'success': false, 'message': e.message ?? 'Failed to like post'},
        (data) => data != null ? data as Map<String, dynamic> : {},
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> unlikePost(int postId) async {
    try {
      final response = await _dioClient.delete('/posts/$postId/unlike');
      // Data contains 'likes_count'
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {'success': false, 'message': e.message ?? 'Failed to unlike post'},
        (data) => {},
      );
    }
  }

  Future<ApiResponse<List<Comment>>> getCommentsForPost(
    int postId, {
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '/posts/$postId/comments',
        queryParameters: {'page': page},
      );
      // Assuming paginated response structure: response.data['data']['data']
      final paginatedData = response.data['data'];
      final List<dynamic> commentListJson =
          paginatedData['data'] as List<dynamic>;
      final comments =
          commentListJson
              .map((json) => Comment.fromJson(json as Map<String, dynamic>))
              .toList();
      return ApiResponse(
        success: true,
        data: comments,
        message: "Comments fetched",
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to fetch comments',
        data: null,
      );
    }
  }

  Future<ApiResponse<Comment>> createComment(
    int postId,
    String content, {
    int? parentCommentId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/posts/$postId/comments',
        data: {
          'content': content,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Comment.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<Comment>(
        success: false,
        message:
            e.response?.data?['message'] ??
            e.message ??
            'Failed to create comment',
        data: null,
      );
    }
  }

  // USER PROFILE
  Future<ApiResponse<User?>> getUserProfile(int userId) async {
    try {
      final response = await _dioClient.get('/users/$userId');
      return ApiResponse.fromJson(
        response.data,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {
              'success': false,
              'message': e.message ?? 'Failed to get user profile',
            },
        (data) => null,
      );
    }
  }

  Future<ApiResponse<User?>> updateUserProfile(Map<String, String> data) async {
    try {
      final response = await _dioClient.put(
        '/profile',
        data: data,
      ); // Assuming PUT for profile update
      return ApiResponse.fromJson(
        response.data,
        (data) => User.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {
              'success': false,
              'message': e.message ?? 'Failed to update profile',
            },
        (data) => null,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserAvatar(
    MultipartFile avatarFile,
  ) async {
    try {
      FormData formData = FormData.fromMap({'avatar': avatarFile});
      final response = await _dioClient.post(
        '/profile/avatar',
        data: formData,
      ); // POST for avatar
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      ); // returns {avatar_url: '...'}
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {
              'success': false,
              'message': e.message ?? 'Failed to update avatar',
            },
        (data) => data != null ? data as Map<String, dynamic> : {},
      );
    }
  }

  Future<ApiResponse<List<Post>>> getUserPosts(
    int userId, {
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '/users/$userId/posts',
        queryParameters: {'page': page},
      );
      final paginatedData = response.data['data'];
      final List<dynamic> postListJson = paginatedData['data'] as List<dynamic>;
      final posts =
          postListJson
              .map((json) => Post.fromJson(json as Map<String, dynamic>))
              .toList();
      return ApiResponse(
        success: true,
        data: posts,
        message: "User posts fetched",
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to fetch user posts',
        data: null,
      );
    }
  }

 Future<ApiResponse<List<Message>>> getConversations({int page = 1}) async {
  try {
    final response = await _dioClient.get('/messages/conversations', queryParameters: {'page': page});
    // Laravel's default pagination is wrapped in its own 'data' key by the paginator object
    // Your sendResponse also wraps everything in a 'data' key.
    // So, response.data['data'] is the paginator object.
    // And response.data['data']['data'] is the actual list of messages.

    // First, check if the overall response and the top-level 'data' are successful
    if (response.data != null && response.data['success'] == true && response.data['data'] != null) {
      final paginatedData = response.data['data']; // This is the Laravel Paginator object

      // Ensure 'data' key exists within the paginatedData (the array of messages)
      if (paginatedData['data'] is List) {
        final List<dynamic> conversationListJson = paginatedData['data'] as List<dynamic>;
        final conversations = conversationListJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        // You might want to return the full paginator object if you need pagination controls in UI
        // For now, just the list of messages:
        return ApiResponse(
            success: true,
            data: conversations,
            message: response.data['message'] ?? "Conversations fetched");
      } else {
        // 'data' key within paginatedData is not a list or is missing
        print("API_PROVIDER_CONVERSATIONS: 'data' array missing in paginated response.");
        return ApiResponse(success: false, message: "Unexpected response format for conversations list.", data: null);
      }
    } else {
      // Top-level response structure is not as expected
      print("API_PROVIDER_CONVERSATIONS: Invalid top-level response structure. Success: ${response.data?['success']}, Data: ${response.data?['data']}");
      return ApiResponse(success: false, message: response.data?['message'] ?? "Failed to fetch conversations.", data: null);
    }

  } on DioException catch (e) {
    String errorMessage = e.message ?? 'Failed to fetch conversations (Dio).';
    if (e.response?.data != null && e.response!.data is Map) {
        final responseMap = e.response!.data as Map<String, dynamic>;
        errorMessage = responseMap['message'] as String? ?? errorMessage;
    }
    print("API_PROVIDER_CONVERSATIONS: DioException - $errorMessage");
    return ApiResponse(success: false, message: errorMessage, data: null);
  } catch (e, s) {
    print("API_PROVIDER_CONVERSATIONS: Unexpected error - $e\n$s");
    return ApiResponse(success: false, message: 'An unexpected error occurred: ${e.toString()}', data: null);
  }
}
  Future<ApiResponse<List<Message>>> getMessagesWithUser(
    int userId, {
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '/messages/with/$userId',
        queryParameters: {'page': page},
      );
      final paginatedData = response.data['data'];
      final List<dynamic> messageListJson =
          paginatedData['data'] as List<dynamic>;
      final messages =
          messageListJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
      return ApiResponse(
        success: true,
        data: messages,
        message: "Messages fetched",
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to fetch messages',
        data: null,
      );
    }
  }

  Future<ApiResponse<Message>> sendMessage(
    int receiverId,
    String messageContent,
  ) async {
    try {
      final response = await _dioClient.post(
        '/messages',
        data: {'receiver_id': receiverId, 'message': messageContent},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Message.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ??
            {
              'success': false,
              'message': e.message ?? 'Failed to send message',
            },
        (data) =>
            data != null
                ? Message.fromJson(data as Map<String, dynamic>)
                : throw Exception('No message data'),
      );
    }
  }

  // Example: Search Users
  Future<ApiResponse<List<User>>> searchUsers(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '/search/users',
        queryParameters: {'query': query, 'page': page},
      );
      // Adjust parsing based on your API response for search results (likely paginated)
      final List<dynamic> userListJson =
          response.data['data']['data'] as List<dynamic>;
      final users =
          userListJson
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
      return ApiResponse(
        success: true,
        data: users,
        message: "Users search results",
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to search users',
        data: null,
      );
    }
  }

  // Example: Search Posts
  Future<ApiResponse<List<Post>>> searchPosts(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await _dioClient.get(
        '/search/posts',
        queryParameters: {'query': query, 'page': page},
      );
      final List<dynamic> postListJson =
          response.data['data']['data'] as List<dynamic>;
      final posts =
          postListJson
              .map((json) => Post.fromJson(json as Map<String, dynamic>))
              .toList();
      return ApiResponse(
        success: true,
        data: posts,
        message: "Posts search results",
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Failed to search posts',
        data: null,
      );
    }
  }
  
Future<ApiResponse<dynamic>> followUser(int userId) async {
    try {
      final response = await _dioClient.post('/users/$userId/follow');
      return ApiResponse.fromJson(response.data, (data) => data); // Data might just be a message
    } on DioException catch (e) {
      return ApiResponse.fromJson(e.response?.data ?? {'success': false, 'message': e.message ?? 'Failed to follow user'}, (data) => null);
    }
  }

  Future<ApiResponse<dynamic>> unfollowUser(int userId) async {
    try {
      final response = await _dioClient.delete('/users/$userId/unfollow');
      return ApiResponse.fromJson(response.data, (data) => data);
    } on DioException catch (e) {
      return ApiResponse.fromJson(e.response?.data ?? {'success': false, 'message': e.message ?? 'Failed to unfollow user'}, (data) => null);
    }
  }

  Future<ApiResponse<List<User>>> getFollowingList(int userId, {int page = 1}) async {
    try {
      final response = await _dioClient.get('/users/$userId/following', queryParameters: {'page': page});
      final paginatedData = response.data['data'];
      final List<dynamic> userListJson = paginatedData['data'] as List<dynamic>;
      final users = userListJson.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: users, message: "Following list fetched");
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data?['message'] ?? 'Failed to fetch following list', data: null);
    }
  }

  Future<ApiResponse<List<User>>> getFollowersList(int userId, {int page = 1}) async {
    try {
      final response = await _dioClient.get('/users/$userId/followers', queryParameters: {'page': page});
      final paginatedData = response.data['data'];
      final List<dynamic> userListJson = paginatedData['data'] as List<dynamic>;
      final users = userListJson.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: users, message: "Followers list fetched");
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data?['message'] ?? 'Failed to fetch followers list', data: null);
    }
  }
}
