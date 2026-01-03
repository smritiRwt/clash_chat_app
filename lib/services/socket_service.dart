import 'package:chat_app/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  // Callbacks for socket events
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onMessageSent;
  Function(String userId)? onUserOnline;
  Function(String userId)? onUserOffline;
  Function(String userId)? onTyping;
  Function(String userId)? onStopTyping;
  Function(String messageId)? onMessageRead;
  Function(String message)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected => _isConnected;

  /// Connect to socket server with access token
  void connect(String accessToken) {
    if (_isConnected && _socket != null) {
      print('⚠️ Socket already connected');
      return;
    }

    _socket = IO.io(
      Constants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': accessToken})
          .build(),
    );

    _setupEventHandlers();
  }

  /// Setup all socket event handlers
  void _setupEventHandlers() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅ Connected to socket');
      onConnected?.call();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('❌ Disconnected from socket');
      onDisconnected?.call();
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      print('⚠️ Connection error: $err');
      onError?.call('Connection error: $err');
    });

    // Message events
    _socket!.on('receive_message', (data) {
      print('📩 Message received: $data');
      if (data is Map<String, dynamic>) {
        onMessageReceived?.call(data);
      }
    });

    _socket!.on('message_sent', (data) {
      print('✅ Message sent: $data');
      if (data is Map<String, dynamic>) {
        onMessageSent?.call(data);
      }
    });

    // User status events
    _socket!.on('user_online', (data) {
      print('🟢 User online: $data');
      if (data is Map<String, dynamic> && data['userId'] != null) {
        onUserOnline?.call(data['userId']);
      }
    });

    _socket!.on('user_offline', (data) {
      print('⚫ User offline: $data');
      if (data is Map<String, dynamic> && data['userId'] != null) {
        onUserOffline?.call(data['userId']);
      }
    });

    // Typing events
    _socket!.on('typing', (data) {
      print('⌨️ User typing: $data');
      if (data is Map<String, dynamic> && data['userId'] != null) {
        onTyping?.call(data['userId']);
      }
    });

    _socket!.on('stop_typing', (data) {
      print('⏸️ User stopped typing: $data');
      if (data is Map<String, dynamic> && data['userId'] != null) {
        onStopTyping?.call(data['userId']);
      }
    });

    // Message read event
    _socket!.on('message_read', (data) {
      print('👁️ Message read: $data');
      if (data is Map<String, dynamic> && data['messageId'] != null) {
        onMessageRead?.call(data['messageId']);
      }
    });

    // Error event
    _socket!.on('error', (data) {
      print('❌ Socket error: $data');
      if (data is Map<String, dynamic> && data['message'] != null) {
        onError?.call(data['message']);
      }
    });
  }

  /// Send a message to a user
  void sendMessage(
    String receiverId,
    String content, {
    String messageType = 'text',
  }) {
    if (!_isConnected || _socket == null) {
      print('❌ Socket not connected. Cannot send message.');
      onError?.call('Socket not connected');
      return;
    }

    final data = {
      'receiverId': receiverId,
      'content': content,
      'messageType': messageType,
    };

    print('📤 Sending message: $data');
    _socket!.emit('send_message', data);
  }

  /// Emit typing indicator
  void emitTyping(String receiverId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('typing', {'receiverId': receiverId});
    print('⌨️ Emitting typing to: $receiverId');
  }

  /// Emit stop typing indicator
  void emitStopTyping(String receiverId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('stop_typing', {'receiverId': receiverId});
    print('⏸️ Emitting stop typing to: $receiverId');
  }

  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('message_read', {'messageId': messageId});
    print('👁️ Marking message as read: $messageId');
  }

  /// Disconnect from socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 Socket disconnected and disposed');
    }
  }

  /// Clear all callbacks
  void clearCallbacks() {
    onMessageReceived = null;
    onMessageSent = null;
    onUserOnline = null;
    onUserOffline = null;
    onTyping = null;
    onStopTyping = null;
    onMessageRead = null;
    onError = null;
    onConnected = null;
    onDisconnected = null;
  }

  /// Reconnect to socket
  void reconnect() {
    if (_socket != null) {
      _socket!.connect();
      print('🔄 Reconnecting socket...');
    }
  }
}
