import 'package:cached_network_image/cached_network_image.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sq_connect/app/config/app_colors.dart'; // Your AppColors
import 'package:sq_connect/app/data/models/message_model.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For UIHelpers.getInitials

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showAvatar; // To control if avatar is shown (e.g., only for first message in a sequence from same user)

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true, // Default to showing avatar for other users
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Define colors based on theme and sender
    final Color myBubbleColor = AppColors.primary;
    final Color otherBubbleColor = theme.brightness == Brightness.light
        ? Colors.grey[200]! // Lighter grey for received bubbles
        : Colors.grey[800]!;
    final Color myTextColor = Colors.white;
    final Color otherTextColor = theme.colorScheme.onSurface;
    final Color myTimeColor = Colors.white.withOpacity(0.8);
    final Color otherTimeColor = Colors.grey[600]!;

    // Determine alignment and bubble properties
    final MainAxisAlignment rowMainAxisAlignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final CrossAxisAlignment bubbleCrossAxisAlignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final Color bubbleColor = isMe ? myBubbleColor : otherBubbleColor;
    final Color textColor = isMe ? myTextColor : otherTextColor;
    final Color timeColor = isMe ? myTimeColor : otherTimeColor;

    // Modern bubble shapes with "tail"
    final Radius bubbleRadius = const Radius.circular(20);
    final BorderRadius messageBorderRadius = isMe
        ? BorderRadius.only(
            topLeft: bubbleRadius,
            topRight: bubbleRadius,
            bottomLeft: bubbleRadius,
            bottomRight: const Radius.circular(5), // Tail for sent messages
          )
        : BorderRadius.only(
            topLeft: const Radius.circular(5), // Tail for received messages
            topRight: bubbleRadius,
            bottomRight: bubbleRadius,
            bottomLeft: bubbleRadius,
          );

    Widget avatarWidget = const SizedBox(width: 40); // Placeholder or space if no avatar
    if (!isMe && showAvatar && message.sender.avatarUrl != null) {
      avatarWidget = Padding(
        padding: const EdgeInsets.only(right: 8.0), // Space between avatar and bubble
        child: CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider(message.sender.avatarUrl!),
        ),
      );
    } else if (!isMe && showAvatar) {
      avatarWidget = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.secondary.withOpacity(0.3), // A fallback color
          child: Text(
            UIHelpers.getInitials(message.sender.name),
            style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }


    Widget messageContent = Flexible(
      child: Column(
        crossAxisAlignment: bubbleCrossAxisAlignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7), // Max width of bubble
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: messageBorderRadius,
              boxShadow: [ // Subtle shadow for all bubbles now for depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                )
              ],
            ),
            child: Text(
              message.message,
              style: TextStyle(color: textColor, fontSize: 15.5, height: 1.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 8.0, right: 8.0),
            child: Text(
              DateFormat.jm().format(message.createdAt.toLocal()),
              style: TextStyle(fontSize: 11, color: timeColor),
            ),
          ),
        ],
      ),
    );

    return Container(
      // Add vertical padding based on whether avatar is shown for previous message
      // This logic would be in the ListView builder usually
      padding: EdgeInsets.only(
        left: isMe ? 0 : (showAvatar ? 12.0 : 12.0 + 40.0 - 8.0), // Indent if no avatar to align with previous bubble with avatar
        right: isMe ? (showAvatar ? 12.0 : 12.0 + 40.0 - 8.0) : 0, // Or simply 12.0 for both if avatar always shown/hidden consistently
        top: 5.0,
        bottom: 5.0,
      ),
      child: Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.end, // Align items (avatar and bubble column) to the bottom
        children: isMe
            ? [messageContent] // My messages don't show my avatar next to them
            : [avatarWidget, messageContent],
      ),
    );
  }
}