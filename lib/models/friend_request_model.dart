import 'friend_model.dart';

/// Friend Request Model
/// Represents a pending friend request
class FriendRequestModel {
  final String id;
  final FriendModel requester;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.requester,
    required this.status,
    required this.createdAt,
  });

  /// Create FriendRequestModel from JSON
  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['_id'] as String,
      requester: FriendModel.fromJson(
        json['requester'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert FriendRequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'requester': requester.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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
