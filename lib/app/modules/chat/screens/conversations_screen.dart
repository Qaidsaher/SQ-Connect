// conversations_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/modules/chat/conversations_controller.dart';
import 'package:sq_connect/app/modules/chat/widgets/conversation_tile.dart';
import 'package:sq_connect/app/routes/app_routes.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';

class ConversationsScreen extends GetView<ConversationsController> {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: LoadingIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.conversations.isEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.conversations.isEmpty) {
          return const Center(child: Text('No conversations yet.'));
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchConversations(refresh: true),
          child: ListView.separated(
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              // The 'otherUser' is populated by the backend in the Message model for conversations
              final otherUser = conversation.otherUser;
              if (otherUser == null)
                return const SizedBox.shrink(); // Should not happen

              return ConversationTile(
                latestMessage: conversation,
                otherUser: otherUser,
                onTap:
                    () => Get.toNamed(
                      Routes.CHAT,
                      arguments: {'otherUser': otherUser},
                    ),
              );
            },
            separatorBuilder:
                (context, index) => const Divider(height: 0, indent: 70),
          ),
        );
      }),
    );
  }
}
