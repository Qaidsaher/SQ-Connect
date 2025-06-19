import 'package:dio/dio.dart' as dio_package; // For MultipartFile
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/comment_model.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';

class PostRepository {
  final ApiProvider _apiProvider;

  PostRepository(this._apiProvider);

  Future<ApiResponse<List<Post>>> getPosts({int page = 1}) {
    return _apiProvider.getPosts(page: page);
  }

  Future<ApiResponse<Post>> getPost(int postId) {
    return _apiProvider.getPost(postId);
  }

  Future<ApiResponse<Post>> createPost(
    String content, {
    List<dio_package.MultipartFile>? attachments,
  }) {
    return _apiProvider.createPost(content, attachments: attachments);
  }

  Future<ApiResponse<Post>> updatePost(int postId, String content) {
    // TODO: Implement updatePost in ApiProvider
    // return _apiProvider.updatePost(postId, content);
    throw UnimplementedError("updatePost not implemented in repository yet.");
  }

  Future<ApiResponse<dynamic>> deletePost(int postId) {
    // TODO: Implement deletePost in ApiProvider
    // return _apiProvider.deletePost(postId);
    throw UnimplementedError("deletePost not implemented in repository yet.");
  }

  Future<ApiResponse<Map<String, dynamic>>> likePost(int postId) {
    return _apiProvider.likePost(postId);
  }

  Future<ApiResponse<Map<String, dynamic>>> unlikePost(int postId) {
    return _apiProvider.unlikePost(postId);
  }

  Future<ApiResponse<List<Comment>>> getCommentsForPost(
    int postId, {
    int page = 1,
  }) {
    return _apiProvider.getCommentsForPost(postId, page: page);
  }

  Future<ApiResponse<Comment>> createComment(
    int postId,
    String content, {
    int? parentCommentId,
  }) {
    return _apiProvider.createComment(
      postId,
      content,
      parentCommentId: parentCommentId,
    );
  }

  Future<ApiResponse<List<Post>>> searchPosts(String query, {int page = 1}) {
    // Basic validation in repository can be good too, or rely on controller/ApiProvider
    if (query.trim().isEmpty) {
      return Future.value(
        ApiResponse(
          success: false,
          data: [],
          message: "Search query cannot be empty.",
        ),
      );
    }
    return _apiProvider.searchPosts(query, page: page);
  }
}
