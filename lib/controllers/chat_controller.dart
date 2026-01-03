import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message_model.dart';
import '../services/socket_service.dart';

/// Chat Controller
/// Manages chat messages and interactions - 100% business logic
class ChatController extends GetxController {
  SocketService socketService = SocketService();
  // Friend info from arguments
  late String friendId;
  late String friendName;

  // Observable state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showEmojiPicker = false.obs;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  /// Initialize chat with friend data from arguments
  void _initializeChat() {
    try {
      final args = Get.arguments as Map<String, dynamic>;
      friendId = args['friendId'] ?? '';
      friendName = args['friendName'] ?? 'Unknown';

      // Load dummy messages for UI demonstration
      _loadDummyMessages();
    } catch (e) {
      print('❌ Error initializing chat: $e');
      friendId = '';
      friendName = 'Unknown';
    }
  }

  /// Load dummy messages for UI demonstration
  void _loadDummyMessages() {
    messages.value = [
      ChatMessage(
        id: '1',
        message: 'Hey! How are you?',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        senderName: friendName,
      ),
      ChatMessage(
        id: '2',
        message: 'I\'m doing great! Thanks for asking 😊',
        isMe: true,
        time: DateTime.now().subtract(const Duration(minutes: 9)),
        senderName: 'Me',
      ),
      ChatMessage(
        id: '3',
        message: 'That\'s awesome! Want to catch up later?',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 8)),
        senderName: friendName,
      ),
      ChatMessage(
        id: '4',
        message: 'Sure! Let me know when you\'re free',
        isMe: true,
        time: DateTime.now().subtract(const Duration(minutes: 7)),
        senderName: 'Me',
      ),
    ];
  }

  /// Send a new message
  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    // Create new message
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: text,
      isMe: true,
      time: DateTime.now(),
      senderName: 'Me',
    );

    // Add to messages list
    messages.add(newMessage);

    // Clear input field
    messageController.clear();

    // Auto-scroll to bottom
    _scrollToBottom();

    // Simulate friend response after 2 seconds (for demo purposes)
    _simulateFriendResponse();

    socketService.sendMessage(friendId, newMessage.message);
  }

  /// Simulate friend response (for UI demo only)
  void _simulateFriendResponse() {
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        'Got it! 👍',
        'Sounds good!',
        'Sure thing!',
        'Absolutely!',
        'I agree!',
        'That makes sense',
        'Perfect!',
      ];

      final randomResponse =
          responses[DateTime.now().second % responses.length];

      final friendMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: randomResponse,
        isMe: false,
        time: DateTime.now(),
        senderName: friendName,
      );

      messages.add(friendMessage);
      _scrollToBottom();
    });
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Scroll to bottom on init
  void scrollToBottomOnInit() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  /// Toggle emoji picker
  void toggleEmojiPicker() {
    showEmojiPicker.value = !showEmojiPicker.value;
    if (showEmojiPicker.value) {
      messageFocusNode.unfocus();
    }
  }

  /// Hide emoji picker
  void hideEmojiPicker() {
    if (showEmojiPicker.value) {
      showEmojiPicker.value = false;
    }
  }

  /// On emoji selected
  void onEmojiSelected(String emoji) {
    final text = messageController.text;
    final selection = messageController.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);
    messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + emoji.length,
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
