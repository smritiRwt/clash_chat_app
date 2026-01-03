class ChatMessage {
  final String id;
  final String message;
  final bool isMe;
  final DateTime time;
  final String senderName;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isMe,
    required this.time,
    required this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      isMe: json['isMe'] ?? false,
      time: json['time'] != null
          ? DateTime.parse(json['time'])
          : DateTime.now(),
      senderName: json['senderName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'isMe': isMe,
      'time': time.toIso8601String(),
      'senderName': senderName,
    };
  }
}
