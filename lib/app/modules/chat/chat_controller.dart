import 'package:flutter/material.dart'; // For ScrollController
import 'package:get/get.dart';
import 'package:sq_connect/app/data/models/message_model.dart';
import 'package:sq_connect/app/data/models/user_model.dart';
import 'package:sq_connect/app/data/repositories/message_repository.dart';
import 'package:sq_connect/app/modules/auth/auth_controller.dart';
import 'package:sq_connect/app/ui/utils/helpers.dart'; // For snackbars

class ChatController extends GetxController {
  final MessageRepository _messageRepository;
  final User otherUser;
  final AuthController _authController;

  ChatController({
    required MessageRepository messageRepository,
    required this.otherUser,
    required AuthController authController,
  })  : _messageRepository = messageRepository,
        _authController = authController;

  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs; // For loading older messages
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  // For pagination of older messages
  int _currentPage = 1;
  final RxBool _hasMoreMessages = true.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController messageTextController = TextEditingController();

  User get currentUser => _authController.currentUser.value!;

  @override
  void onInit() {
    super.onInit();
    fetchMessages(initialLoad: true);
    // Listener to load older messages when scrolling to the top
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.minScrollExtent &&
          !isLoadingMore.value &&
          _hasMoreMessages.value) {
        fetchMessages();
      }
    });
  }

  Future<void> fetchMessages({bool initialLoad = false}) async {
    if (initialLoad) {
      messages.clear();
      _currentPage = 1;
      _hasMoreMessages.value = true;
      isLoading.value = true;
    } else {
      if (!_hasMoreMessages.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }
    errorMessage.value = '';

    try {
      // API should return messages oldest first for normal display,
      // or newest first if we are fetching older pages (then we'd insert at start).
      // Let's assume API /messages/with/{user}?page=X returns messages for that page, ordered ASC by default.
      final response = await _messageRepository.getMessagesWithUser(otherUser.id, page: _currentPage);
      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          _hasMoreMessages.value = false;
        } else {
          if (initialLoad) {
            messages.assignAll(response.data!);
          } else {
            // Add older messages to the beginning of the list
            messages.insertAll(0, response.data!);
          }
          _currentPage++;
        }
        if (initialLoad) {
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom(animated: false));
        }
      } else {
        errorMessage.value = response.message;
         _hasMoreMessages.value = false; // Stop trying on error
      }
    } catch (e) {
      errorMessage.value = "Failed to load messages: ${e.toString()}";
       _hasMoreMessages.value = false; // Stop trying on error
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> sendMessage() async {
    final String content = messageTextController.text.trim();
    if (content.isEmpty) return;

    isSending.value = true;
    messageTextController.clear(); // Clear input field immediately

    // Optimistically add message to UI (optional, can make UI feel faster)
    // final optimisticMessage = Message(
    //   id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
    //   senderId: currentUser.id,
    //   receiverId: otherUser.id,
    //   message: content,
    //   isRead: false, // Will be false initially
    //   createdAt: DateTime.now(),
    //   updatedAt: DateTime.now(),
    //   sender: currentUser,
    //   receiver: otherUser,
    // );
    // messages.add(optimisticMessage);
    // scrollToBottom();

    try {
      final response = await _messageRepository.sendMessage(otherUser.id, content);
      if (response.success && response.data != null) {
        // If NOT using optimistic update, add the confirmed message here:
        messages.add(response.data!);
        scrollToBottom();

        // If using optimistic update, you might want to replace the temporary message
        // with the one from the server if it has a real ID or timestamp.
        // final index = messages.indexWhere((m) => m.id == optimisticMessage.id);
        // if (index != -1) messages[index] = response.data!;
      } else {
        UIHelpers.showErrorSnackbar(response.message, title: "Send Failed");
        // If optimistic, remove the failed message or mark it as failed
        // messages.removeWhere((m) => m.id == optimisticMessage.id);
        messageTextController.text = content; // Restore text if send failed
      }
    } catch (e) {
      UIHelpers.showErrorSnackbar("Failed to send message: ${e.toString()}");
      // messages.removeWhere((m) => m.id == optimisticMessage.id);
      messageTextController.text = content;
    } finally {
      isSending.value = false;
    }
  }

  void scrollToBottom({bool animated = true}) {
    if (messages.isNotEmpty && scrollController.hasClients) {
      // Needs a slight delay for the ListView to build after adding a new item
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) { // Check again
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: animated ? 300 : 0),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageTextController.dispose();
    super.onClose();
  }
}