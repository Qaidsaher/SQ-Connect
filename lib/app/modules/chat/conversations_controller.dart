// conversations_controller.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/message_model.dart';
import 'package:sq_connect/app/data/repositories/message_repository.dart';

class ConversationsController extends GetxController {
  final MessageRepository _messageRepository;
  ConversationsController(this._messageRepository);

  final RxList<Message> conversations =
      <Message>[].obs; // Stores the latest message of each conversation
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations({bool refresh = false}) async {
    if (refresh) conversations.clear();
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _messageRepository.getConversations();
      if (response.success && response.data != null) {
        conversations.assignAll(response.data!);
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorMessage.value = "Failed to load conversations: ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }
}
