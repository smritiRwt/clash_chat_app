class FriendModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String status;
  final String friendshipStatus;

  FriendModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.status,
    required this.friendshipStatus,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      status: json['status'] ?? 'offline',
      friendshipStatus: json['friendshipStatus'] ?? 'none',
    );
  }

  /// Create a copy with updated fields
  FriendModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? status,
    String? friendshipStatus,
  }) {
    return FriendModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      friendshipStatus: friendshipStatus ?? this.friendshipStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'status': status,
      'friendshipStatus': friendshipStatus,
    };
  }
}
