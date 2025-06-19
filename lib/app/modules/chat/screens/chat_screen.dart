import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sq_connect/app/config/app_colors.dart'; // Your AppColors
import 'package:sq_connect/app/modules/chat/chat_controller.dart';
import 'package:sq_connect/app/modules/chat/widgets/chat_bubble.dart';
import 'package:sq_connect/app/ui/global_widgets/loading_indicator.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For UIHelpers

class ChatScreen extends GetView<ChatController> {
  ChatScreen({super.key});

  // _messageTextController is now managed by ChatController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildModernAppBar(context),
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? Colors.grey[100] // Light background for chat
              : Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: LoadingIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[300],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () => controller.fetchMessages(initialLoad: true),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (controller.messages.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet. Say hi to ${controller.otherUser.name}!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // ListView starts from top now, new messages added to bottom
              return Column(
                children: [
                  Obx(() {
                    // Loading indicator for older messages
                    if (controller.isLoadingMore.value) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LoadingIndicator(size: 24),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Expanded(
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      // reverse: false, // Default, messages flow top to bottom
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[index];
                        final isMe =
                            message.senderId == controller.currentUser.id;
                        return ChatBubble(message: message, isMe: isMe);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
          _buildModernMessageInputField(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    // Online status (dummy for now, you'd get this from user model or presence system)
    bool isOnline = true; // Replace with actual logic

    return AppBar(
      elevation: 0.5, // Subtle elevation
      backgroundColor:
          Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).primaryColor,
      leadingWidth: 30, // To reduce default padding for back button
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                controller.otherUser.avatarUrl != null
                    ? CachedNetworkImageProvider(
                      controller.otherUser.avatarUrl!,
                    )
                    : null,
            child:
                controller.otherUser.avatarUrl == null
                    ? Text(UIHelpers.getInitials(controller.otherUser.name))
                    : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.otherUser.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isOnline) // Show online status if available
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined),
          tooltip: "Voice Call (WIP)",
          onPressed:
              () =>
                  UIHelpers.showInfoSnackbar("Voice call feature coming soon!"),
        ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          tooltip: "Video Call (WIP)",
          onPressed:
              () =>
                  UIHelpers.showInfoSnackbar("Video call feature coming soon!"),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed:
              () => UIHelpers.showInfoSnackbar("this feature coming soon!"),
        ),
      ],
    );
  }

  Widget _buildModernMessageInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.0,
        right: 8.0,
        top: 8.0,
        bottom:
            MediaQuery.of(context).padding.bottom + 8.0, // Safe area for bottom
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .end, // Align items to bottom for multi-line TextField
        children: [
          // Optional: Attachment button
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed:
                () => UIHelpers.showInfoSnackbar("this feature coming soon!"),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[100]
                        : Colors.grey[800],
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Optional: Emoji button
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey[600],
                    ),
                    onPressed:
                        () => UIHelpers.showInfoSnackbar(
                          "this feature coming soon!",
                        ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageTextController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      minLines: 1,
                      maxLines: 5, // Allow up to 5 lines before scrolling
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () =>
                controller.isSending.value
                    ? Container(
                      // Container to match button size
                      padding: const EdgeInsets.all(10.0),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                    : Material(
                      // For ink splash on CircleAvatar
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap:
                            controller.isSending.value
                                ? null
                                : controller.sendMessage,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
