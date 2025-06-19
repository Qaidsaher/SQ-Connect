// message_repository.
import 'package:sq_connect/app/data/models/api_response_model.dart';
import 'package:sq_connect/app/data/models/message_model.dart';
import 'package:sq_connect/app/data/providers/api_provider.dart';

class MessageRepository {
  final ApiProvider _apiProvider;

  MessageRepository(this._apiProvider);

  Future<ApiResponse<List<Message>>> getConversations({int page = 1}) {
    return _apiProvider.getConversations(page: page);
  }

  Future<ApiResponse<List<Message>>> getMessagesWithUser(int userId, {int page = 1}) {
    return _apiProvider.getMessagesWithUser(userId, page: page);
  }

  Future<ApiResponse<Message>> sendMessage(int receiverId, String messageContent) {
    return _apiProvider.sendMessage(receiverId, messageContent);
  }
}