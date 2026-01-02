import 'friend_model.dart';

/// Sent Request Model
/// Represents a sent friend request
class SentRequestModel {
  final String id;
  final FriendModel recipient;
  final String status;
  final DateTime createdAt;

  SentRequestModel({
    required this.id,
    required this.recipient,
    required this.status,
    required this.createdAt,
  });

  /// Create SentRequestModel from JSON
  factory SentRequestModel.fromJson(Map<String, dynamic> json) {
    return SentRequestModel(
      id: json['_id'] as String,
      recipient: FriendModel.fromJson(
        json['recipient'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert SentRequestModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipient': recipient.toJson(),
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
