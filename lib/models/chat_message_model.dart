class ChatMessage {
  final String id;
  final String message;
  final bool isMe;
  final DateTime time;
  final String senderName;
  final String status;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isMe,
    required this.time,
    required this.senderName,
    required this.status,
  });

  ChatMessage copyWith({
    String? status,
  }) {
    return ChatMessage(
      id: id,
      message: message,
      isMe: isMe,
      time: time,
      senderName: senderName,
      status: status ?? this.status,
    );
  }
}
