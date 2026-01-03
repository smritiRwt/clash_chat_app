import 'package:chat_app/models/chat_response_model/chat_response_model.dart';
import 'package:chat_app/services/api_client.dart';
import 'package:chat_app/services/db_helper.dart';
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
    final ApiClient _apiClient = ApiClient();


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

      // Set up socket listener for incoming messages
      _setupSocketListeners();

      // Load messages from API
      _loadChatMessages();
    } catch (e) {
      print('❌ Error initializing chat: $e');
      friendId = '';
      friendName = 'Unknown';
    }
  }

  /// Set up socket listeners for real-time message updates
  void _setupSocketListeners() {
    // Listen for incoming messages
    socketService.onMessageReceived = (data) {
      print('📩 Received message in ChatController: $data');
      _handleIncomingMessage(data);
    };

    // Listen for message sent confirmation
    socketService.onMessageSent = (data) {
      print('✅ Message sent confirmation: $data');
      // Optionally update message status to "sent"
    };
  }

  /// Handle incoming message from socket
  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      // Parse the incoming message data
      final messageId = data['_id'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final content = data['content'] ?? data['message'] ?? '';
      final senderId = data['sender']?['_id'] ?? data['sender']?['id'] ?? data['senderId'] ?? '';
      final senderName = data['sender']?['username'] ?? data['sender']?['name'] ?? data['senderName'] ?? friendName;
      final timestamp = data['createdAt'] ?? data['timestamp'];
      
      // Only add message if it's from the current chat friend
      if (senderId == friendId) {
        final newMessage = ChatMessage(
          id: messageId,
          message: content,
          isMe: false, // Incoming message is from friend
          time: timestamp != null ? DateTime.parse(timestamp) : DateTime.now(),
          senderName: senderName,
        );

        // Add to messages list
        messages.add(newMessage);
        
        // Auto-scroll to bottom
        _scrollToBottom();
        
        print('✅ Message added to list: ${newMessage.message}');
      }
    } catch (e) {
      print('❌ Error handling incoming message: $e');
    }
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

    // Send message via socket
    socketService.sendMessage(friendId, newMessage.message);
  }

 /// Load chat messages from API
Future<void> _loadChatMessages() async {
  try {
    isLoading.value = true;
    
    final token = await getAccessToken();
    if (token == null) {
      print('❌ No access token found');
      isLoading.value = false;
      return;
    }

    // Ensure token is set in API client
    _apiClient.setAuthToken(token);
    
    // Fetch chat messages from API
    final response = await _apiClient.getRequest(
      '/messages/$friendId',
      queryParameters: {'skip': 0, 'limit': 50},
      headers: {'Authorization': 'Bearer $token'},
    );

    print('📥 Response Data: $response');

    // Parse response - data is nested inside 'data' object
    if (response['data'] != null && response['data']['messages'] != null) {
      final chatResponseModel = ChatResponseModel.fromJson(response['data']);
      
      if (chatResponseModel.messages != null && chatResponseModel.messages!.isNotEmpty) {
        // Convert API messages to ChatMessage model
        messages.value = chatResponseModel.messages!.map((apiMessage) {
          // Determine if message is from current user
          final isMe = apiMessage.sender?.id != friendId;
          
          return ChatMessage(
            id: apiMessage.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            message: apiMessage.content ?? '',
            isMe: isMe,
            time: apiMessage.createdAt ?? DateTime.now(),
            senderName: isMe ? 'Me' : (apiMessage.sender?.username ?? friendName),
          );
        }).toList();
        
        print('✅ Loaded ${messages.length} chat messages');
        
        // Store unread count if needed
        if (chatResponseModel.unreadCount != null) {
          print('📬 Unread messages: ${chatResponseModel.unreadCount}');
        }
      } else {
        messages.value = [];
        print('⚠️ No messages found');
      }
    } else {
      messages.value = [];
      print('⚠️ Invalid response format');
    }
    
    isLoading.value = false;
  } catch (e) {
    print('❌ Error loading chat messages: $e');
    isLoading.value = false;
    messages.value = [];
  }
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

    /// Get access token from SQLite
  Future<String?> getAccessToken() async {
    try {
      DBHelper dbHelper = DBHelper();
      final token = await dbHelper.getAccessToken();
      return token;
    } catch (e) {
      print('❌ Error getting access token: $e');
      return null;
    }
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
    
    // Handle invalid selection positions
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    
    final newText = text.replaceRange(start, end, emoji);
    messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + emoji.length,
      ),
    );
  }

  @override
  void onClose() {
    // Clear socket callbacks when controller is disposed
    socketService.onMessageReceived = null;
    socketService.onMessageSent = null;
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
