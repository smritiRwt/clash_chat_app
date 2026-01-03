class ChatListModel {
  final String friendId;
  final FriendInfo friend;
  final LastMessage lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatListModel({
    required this.friendId,
    required this.friend,
    required this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      friendId: json['friendId'] as String,
      friend: FriendInfo.fromJson(json['friend'] as Map<String, dynamic>),
      lastMessage: LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: json['unreadCount'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class FriendInfo {
  final String id;
  final String username;
  final String? avatar;

  FriendInfo({
    required this.id,
    required this.username,
    this.avatar,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['_id'] as String,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}

class LastMessage {
  final String id;
  final String content;
  final String messageType;
  final String status;
  final DateTime createdAt;
  final SenderInfo sender;

  LastMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.status,
    required this.createdAt,
    required this.sender,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['_id'] as String,
      content: json['content'] as String,
      messageType: json['messageType'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: SenderInfo.fromJson(json['sender'] as Map<String, dynamic>),
    );
  }
}

class SenderInfo {
  final String id;
  final String username;

  SenderInfo({
    required this.id,
    required this.username,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'] as String,
      username: json['username'] as String,
    );
  }
}

class ChatListResponse {
  final bool success;
  final String message;
  final ChatListData data;

  ChatListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    return ChatListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ChatListData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ChatListData {
  final List<ChatListModel> chats;
  final int total;
  final bool hasMore;

  ChatListData({
    required this.chats,
    required this.total,
    required this.hasMore,
  });

  factory ChatListData.fromJson(Map<String, dynamic> json) {
    return ChatListData(
      chats: (json['chats'] as List)
          .map((chat) => ChatListModel.fromJson(chat as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}
