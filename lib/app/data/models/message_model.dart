// message_model.dart
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User sender;
  final User receiver;
  // For conversation list
  User? otherUser;
  int? unreadCount;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.receiver,
    this.otherUser,
    this.unreadCount,
  });

  // lib/app/data/models/message_model.dart
  factory Message.fromJson(Map<String, dynamic> json) {
    // print("Message.fromJson input: $json"); // Keep for debugging

    User? parsedSender;
    if (json['sender'] != null && json['sender'] is Map<String, dynamic>) {
      parsedSender = User.fromJson(json['sender'] as Map<String, dynamic>);
    } else if (json['sender_id'] != null &&
        json['other_user'] != null &&
        json['other_user']['id'] != json['sender_id']) {
      // This case is for conversations where 'sender' is unset but we can infer it if needed.
      // However, for conversations, we primarily care about 'other_user'.
      // If 'other_user' IS the sender, then this would be wrong.
      // Let's assume for general messages, 'sender' and 'receiver' are present.
      // For conversations, 'other_user' is primary.
    }

    User? parsedReceiver;
    if (json['receiver'] != null && json['receiver'] is Map<String, dynamic>) {
      parsedReceiver = User.fromJson(json['receiver'] as Map<String, dynamic>);
    } else if (json['receiver_id'] != null &&
        json['other_user'] != null &&
        json['other_user']['id'] != json['receiver_id']) {
      // Similar logic for receiver if needed for general messages.
    }

    User? parsedOtherUser;
    if (json['other_user'] != null &&
        json['other_user'] is Map<String, dynamic>) {
      parsedOtherUser = User.fromJson(
        json['other_user'] as Map<String, dynamic>,
      );
    }

    // Determine the effective sender and receiver for the Message model based on context
    // For a general message, sender and receiver are explicit.
    // For a conversation list item, we have other_user. The original sender/receiver are implicit.
    // We need to ensure our Message model fields are populated.
    // The `senderId` and `receiverId` are always present in the base message.

    // If 'sender' and 'receiver' keys are missing (likely from conversation list due to unset)
    // we rely on 'other_user' and the original 'sender_id'/'receiver_id'
    // The AuthController's current user ID is needed to determine who 'sender' and 'receiver' are in context of 'other_user'
    final AuthController authController =
        Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : Get.put(
              AuthController(Get.find(), Get.find()),
              permanent: true,
            ); // Ensure AuthController is available
    final currentUserId = authController.currentUser.value?.id;

    User finalSender;
    User finalReceiver;

    if (parsedOtherUser != null && currentUserId != null) {
      // This is likely a conversation item
      if (json['sender_id'] == currentUserId) {
        finalSender = authController.currentUser.value!;
        finalReceiver = parsedOtherUser;
      } else {
        finalSender = parsedOtherUser;
        finalReceiver = authController.currentUser.value!;
      }
    } else if (parsedSender != null && parsedReceiver != null) {
      // This is likely a regular message item where sender/receiver are explicit
      finalSender = parsedSender;
      finalReceiver = parsedReceiver;
    } else {
      // Fallback or error state - this shouldn't happen with well-formed API responses
      // Create placeholder users to avoid null errors, but log this issue.
      print(
        "ERROR Message.fromJson: Could not determine finalSender/finalReceiver for message id ${json['id']}. JSON: $json",
      );
      final placeholderUser = User(
        id: 0,
        name: "Unknown",
        email: "",
        username: "unknown",
        role: "user",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      finalSender =
          json['sender_id'] != null
              ? User(
                id: json['sender_id'],
                name: "Sender ${json['sender_id']}",
                email: "",
                username: "sender_${json['sender_id']}",
                role: "user",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
              : placeholderUser;
      finalReceiver =
          json['receiver_id'] != null
              ? User(
                id: json['receiver_id'],
                name: "Receiver ${json['receiver_id']}",
                email: "",
                username: "receiver_${json['receiver_id']}",
                role: "user",
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
              : placeholderUser;
    }

    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sender: finalSender, // Use the determined finalSender
      receiver: finalReceiver, // Use the determined finalReceiver
      otherUser: parsedOtherUser, // This is directly from the 'other_user' key
      unreadCount: json['unread_count'] as int?,
    );
  }
}
