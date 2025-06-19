// comment_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sq_connect/app/data/models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final Function(String content, int parentCommentId)? onReply; // Callback for replying to this comment

  const CommentTile({super.key, required this.comment, this.onReply});

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateFormat.yMMMd().add_jm().format(comment.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: comment.user.avatarUrl != null
                    ? CachedNetworkImageProvider(comment.user.avatarUrl!)
                    : null,
                child: comment.user.avatarUrl == null
                    ? Text(comment.user.name.isNotEmpty ? comment.user.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 14))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '@${comment.user.username} • $timeAgo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          if (onReply != null) // Show reply button if callback is provided
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 4.0), // Align with comment text
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                onPressed: () {
                  // For now, direct reply opens comment box with parentId
                  // A more complex UI would show an inline reply box
                   // onReply!(comment.id); // Pass current comment's ID as parent
                   ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Replying to ${comment.user.name} (ID: ${comment.id}) - UI WIP"))
                   );
                },
                child: const Text('Reply', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
              ),
            ),
          if (comment.replies != null && comment.replies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 8.0), // Indent replies
              child: Column(
                children: comment.replies!.map((reply) => CommentTile(comment: reply, onReply: onReply)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}