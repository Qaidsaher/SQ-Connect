// conversation_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sq_connect/app/data/models/message_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart'; // Make sure this is imported

class ConversationTile extends StatelessWidget {
  final Message latestMessage; // The last message object from the conversation
  final User otherUser; // The user you are conversing with
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.latestMessage,
    required this.otherUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateFormat.jm().format(
      latestMessage.createdAt.toLocal(),
    ); // Just time for latest message

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage:
            otherUser.avatarUrl != null
                ? CachedNetworkImageProvider(otherUser.avatarUrl!)
                : null,
        child:
            otherUser.avatarUrl == null
                ? Text(
                  otherUser.name.isNotEmpty
                      ? otherUser.name[0].toUpperCase()
                      : 'U',
                )
                : null,
      ),
      title: Text(
        otherUser.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        latestMessage.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color:
              latestMessage.unreadCount != null &&
                      latestMessage.unreadCount! > 0
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
          if (latestMessage.unreadCount != null &&
              latestMessage.unreadCount! > 0)
            const SizedBox(height: 4),
          if (latestMessage.unreadCount != null &&
              latestMessage.unreadCount! > 0)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                latestMessage.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
