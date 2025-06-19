// auth_repository.dart

import 'package:dio/dio.dart';
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';

class AuthRepository {
  final ApiProvider _apiProvider;

  AuthRepository(this._apiProvider);

  Future<ApiResponse<Map<String, dynamic>>> login(String login, String password) async {
    return _apiProvider.login(login, password);
  }

  Future<ApiResponse<Map<String, dynamic>>> register(String name, String username, String email, String password, String passwordConfirmation) async {
    return _apiProvider.register(name, username, email, password, passwordConfirmation);
  }

  Future<ApiResponse<User>> getMe() async {
    return _apiProvider.getMe();
  }
   Future<ApiResponse<dynamic>> logout() async {
    return _apiProvider.logout();
  }
}