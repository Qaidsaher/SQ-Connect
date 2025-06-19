// user_repository.
import 'package:dio/dio.dart';
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/post_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';

class UserRepository {
  final ApiProvider _apiProvider;

  UserRepository(this._apiProvider);

  Future<ApiResponse<User?>> getUserProfile(int userId) {
    return _apiProvider.getUserProfile(userId);
  }

  Future<ApiResponse<User?>> updateUserProfile(Map<String, String> data) {
    return _apiProvider.updateUserProfile(data);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserAvatar(
    MultipartFile avatarFile,
  ) {
    return _apiProvider.updateUserAvatar(avatarFile);
  }

  Future<ApiResponse<List<Post>>> getUserPosts(int userId, {int page = 1}) {
    return _apiProvider.getUserPosts(userId, page: page);
  }

  Future<ApiResponse<List<User>>> searchUsers(String query, {int page = 1}) {
    return _apiProvider.searchUsers(query, page: page);
  }

  Future<ApiResponse<dynamic>> followUser(int userId) {
    return _apiProvider.followUser(userId);
  }

  Future<ApiResponse<dynamic>> unfollowUser(int userId) {
    return _apiProvider.unfollowUser(userId);
  }

  Future<ApiResponse<List<User>>> getFollowingList(int userId, {int page = 1}) {
    return _apiProvider.getFollowingList(userId, page: page);
  }

  Future<ApiResponse<List<User>>> getFollowersList(int userId, {int page = 1}) {
    return _apiProvider.getFollowersList(userId, page: page);
  }
}
