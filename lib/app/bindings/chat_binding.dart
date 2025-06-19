// chat_binding.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/modules/chat/chat_controller.dart';
import 'package:sq_connect/app/modules/chat/conversations_controller.dart';

class ConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationsController>(
      () => ConversationsController(Get.find()),
    );
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(
        messageRepository: Get.find(),
        // Pass the other user's User object or ID
        // The argument should be a User object for displaying name/avatar easily
        otherUser:
            Get.arguments['otherUser'] as User, // Ensure User model is passed
        authController: Get.find(),
      ),
    );
  }
}
