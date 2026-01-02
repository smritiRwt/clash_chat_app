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
