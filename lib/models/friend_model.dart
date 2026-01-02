/// Friend Model
/// Represents a friend/user in the system
class FriendModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String status;
  final String friendshipStatus;
  final DateTime? lastSeen;

  FriendModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.status,
    required this.friendshipStatus,
    this.lastSeen,
  });

  /// Create FriendModel from JSON
  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      status: json['status'] as String? ?? 'offline',
      friendshipStatus: json['friendshipStatus'] as String? ?? 'none',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  /// Convert FriendModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'status': status,
      'friendshipStatus': friendshipStatus,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  /// Check if friend is online
  bool get isOnline => status.toLowerCase() == 'online';

  /// Check friendship status
  bool get isFriend => friendshipStatus == 'friends';
  bool get isPending => friendshipStatus == 'pending';
  bool get isNone => friendshipStatus == 'none';

  /// Get formatted last seen time
  String get formattedLastSeen {
    if (lastSeen == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
