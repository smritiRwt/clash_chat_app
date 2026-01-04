import 'dart:async';

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
  final RxBool isFriendTyping = false.obs;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();
  Timer? _typingTimer;

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

  // Map temporary IDs to backend message IDs
  final Map<String, String> _tempIdToBackendId = {};

  /// Set up socket listeners for real-time message updates
  void _setupSocketListeners() {
    // Listen for incoming messages
    socketService.onMessageReceived = (data) {
      print('📩 Received message in ChatController: $data');
      _handleIncomingMessage(data);
    };

    // Listen for message sent confirmation (delivered)
    socketService.onMessageSent = (data) {
      print('📬 Message sent confirmation received: $data');
      print('🔍 Data keys: ${data.keys}');
      print('🆔 Temp ID: ${data['tempId']}');
      print('🆔 Backend ID: ${data['_id']}');
      
      if (data['_id'] != null && data['tempId'] != null) {
        // Map temporary ID to backend ID if both exist
        final tempId = data['tempId'].toString();
        final backendId = data['_id'].toString();
        print('🔄 Mapping temp ID $tempId to backend ID $backendId');
        _tempIdToBackendId[tempId] = backendId;
        _updateMessageStatus(tempId, 'delivered');
      } else if (data['content'] != null) {
        // Fallback: match by content and find the most recent sent message
        final content = data['content'].toString();
        print('🔍 Using fallback content matching: "$content"');
        final index = messages.indexWhere((m) => 
          m.isMe && 
          m.message == content && 
          m.status == 'sent'
        );
        
        if (index != -1) {
          final tempId = messages[index].id;
          final backendId = data['_id'].toString();
          print('🔄 Found message at index $index, mapping temp ID $tempId to backend ID $backendId');
          _tempIdToBackendId[tempId] = backendId;
          _updateMessageStatus(tempId, 'delivered');
        } else {
          print('⚠️ No matching sent message found for content: "$content"');
        }
      } else {
        print('⚠️ Message confirmation data missing required fields');
      }
    };

    // typing indicator start
    socketService.onTyping = (userId) {
      if (userId == friendId) {
        isFriendTyping.value = true;
        _scrollToBottom(); // keeps typing visible
      }
    };

    // typing indicator stop
    socketService.onStopTyping = (userId) {
      if (userId == friendId) {
        isFriendTyping.value = false;
      }
    };

    //
    socketService.onMessageRead = (messageId) {
      print('👁️ Message read: $messageId');
      final backendId = messageId.toString();
      
      // First try to find by temporary ID (for sent messages)
      final tempId = _tempIdToBackendId.entries
          .firstWhere((entry) => entry.value == backendId,
              orElse: () => MapEntry('', ''))
          .key;
      
      if (tempId.isNotEmpty) {
        _updateMessageStatus(tempId, 'read');
      } else {
        // If no temp ID found, try direct backend ID (for received messages)
        _updateMessageStatus(backendId, 'read');
      }
    };
  }

  // void _updateMessageStatus(String messageId, String status) {
  //   // Find the message and update its status
  //   for (var message in messages) {
  //     if (message.id == messageId) {
  //       message.status = status;
  //       break;
  //     }
  //   }
  //   // Notify UI to update
  //   messages.refresh();
  // }
  void _updateMessageStatus(String messageId, String status) {
    print('🔍 Looking for message ID: $messageId');
    print('📋 Available message IDs: ${messages.map((m) => m.id).toList()}');
    
    // First try direct ID match
    var index = messages.indexWhere((m) => m.id == messageId);
    
    // If not found and this is a backend ID, try to find by mapping
    if (index == -1 && _tempIdToBackendId.containsValue(messageId)) {
      final tempId = _tempIdToBackendId.entries
          .firstWhere((entry) => entry.value == messageId)
          .key;
      index = messages.indexWhere((m) => m.id == tempId);
    }
    
    if (index != -1) {
      final oldMessage = messages[index];
      print('📝 Found message at index $index, updating status from ${oldMessage.status} to $status');

      messages[index] = oldMessage.copyWith(status: status);
      
      messages.refresh();
      print('✅ Message status updated to: $status for message: $messageId');
    } else {
      print('⚠️ Message not found: $messageId');
      // Debug: show all messages for troubleshooting
      for (int i = 0; i < messages.length; i++) {
        final msg = messages[i];
        print('📧 Message[$i]: id=${msg.id}, status=${msg.status}, isMe=${msg.isMe}');
      }
    }
  }

  void onTextChanged(String text) {
    if (text.isNotEmpty) {
      socketService.emitTyping(friendId);
    }

    // Debounce stop typing
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      socketService.emitStopTyping(friendId);
    });
  }

  /// Handle incoming message from socket
  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      print('📨 Raw incoming message data: $data');
      
      // Parse the incoming message data
      final messageId =
          data['_id'] ??
          data['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final content = data['content'] ?? data['message'] ?? '';
      final senderId =
          data['sender']?['_id'] ??
          data['sender']?['id'] ??
          data['senderId'] ??
          '';
      final senderName =
          data['sender']?['username'] ??
          data['sender']?['name'] ??
          data['senderName'] ??
          friendName;
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String());
      } catch (e) {
        print('⚠️ Error parsing timestamp: ${data['createdAt']}, using current time');
        timestamp = DateTime.now();
      }

      print('🔍 Parsed message:');
      print('   - Message ID: $messageId');
      print('   - Content: "$content"');
      print('   - Sender ID: $senderId');
      print('   - Current Friend ID: $friendId');
      print('   - Sender Name: $senderName');
      print('   - Timestamp: $timestamp');

      // Only add message if it's from the current chat friend
      if (senderId == friendId) {
        print('✅ Message is from current friend - adding to chat');
        
        final newMessage = ChatMessage(
          id: messageId,
          message: content,
          isMe: false, // Incoming message is from friend
          time: timestamp,
          senderName: senderName,
          status: data['status'],
        );

        // Add to messages list
        messages.add(newMessage);
        print('➕ Message added to list: ${newMessage.message}');

        // Auto-scroll to bottom
        _scrollToBottom();

        print('✅ Incoming message processed successfully');
      } else {
        print('⚠️ Message is from different user (sender: $senderId, friend: $friendId) - ignoring');
      }
    } catch (e) {
      print('❌ Error handling incoming message: $e');
      print('📨 Original data that caused error: $data');
    }
  }

  /// Send a new message
  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    print('🚀 Starting message send process...');
    print('📱 Friend ID: $friendId');
    print('🔌 Socket connected: ${socketService.isConnected}');

    socketService.emitStopTyping(friendId);

    // Create new message with temporary ID
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = ChatMessage(
      id: tempId,
      message: text,
      isMe: true,
      time: DateTime.now(),
      senderName: 'Me',
      status: 'sent',
    );

    print('📝 Created message with temp ID: $tempId');
    print('💬 Message content: "$text"');

    // Add to messages list
    messages.add(newMessage);
    print('➕ Message added to local list');

    // Clear input field
    messageController.clear();

    // Auto-scroll to bottom
    _scrollToBottom();

    // Send message via socket with tempId
    print('📡 Sending message via socket...');
    socketService.sendMessage(friendId, newMessage.message, tempId: tempId);
    print('✅ Message send command completed');
  }

  /// Mark messages as read when they are displayed
  void markMessagesAsRead() {
    for (var message in messages) {
      if (!message.isMe && message.status != 'read') {
        socketService.markMessageAsRead(message.id);
      }
    }
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
      if (response['data'] != null && response['data']['chats'] != null) {
        // The API returns chat data, we need to extract messages from the chat
        final chatsData = response['data']['chats'] as List;
        if (chatsData.isNotEmpty) {
          final chatData = chatsData.first as Map<String, dynamic>;
          
          // Check if this chat has messages (might be in a different structure)
          if (chatData.containsKey('messages') && chatData['messages'] != null) {
            final messagesData = chatData['messages'] as List;
            messages.value = messagesData.map((msg) => ChatMessage(
              id: msg['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              message: msg['content'] ?? '',
              isMe: msg['sender']['_id'] != friendId,
              time: DateTime.tryParse(msg['createdAt'] ?? '') ?? DateTime.now(),
              senderName: msg['sender']['_id'] != friendId 
                  ? friendName 
                  : (msg['sender']['username'] ?? 'Me'),
              status: msg['status'] ?? 'sent',
            )).toList();
          } else {
            // No messages in this chat yet
            messages.value = [];
          }
        } else {
          messages.value = [];
        }
      } else if (response['data'] != null && response['data']['messages'] != null) {
        // Handle direct messages response (if API structure changes)
        final chatResponseModel = ChatResponseModel.fromJson(response['data']);

        if (chatResponseModel.messages != null &&
            chatResponseModel.messages!.isNotEmpty) {
          // Convert API messages to ChatMessage model
          messages.value = chatResponseModel.messages!.map((apiMessage) {
            // Determine if message is from current user
            final isMe = apiMessage.sender?.id != friendId;

            return ChatMessage(
              id:
                  apiMessage.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              message: apiMessage.content ?? '',
              isMe: isMe,
              time: apiMessage.createdAt ?? DateTime.now(),
              senderName: isMe
                  ? 'Me'
                  : (apiMessage.sender?.username ?? friendName),
              status: apiMessage.status ?? 'sent',
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
      socketService.emitStopTyping(friendId);
    }
  }

  /// Hide emoji picker
  void hideEmojiPicker() {
    if (showEmojiPicker.value) {
      showEmojiPicker.value = false;
      socketService.emitStopTyping(friendId);
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
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  void onClose() {
    // Clear socket callbacks when controller is disposed
    _typingTimer?.cancel();
    socketService.onMessageReceived = null;
    socketService.onMessageSent = null;
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
}
