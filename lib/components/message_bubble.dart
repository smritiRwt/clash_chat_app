import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message_model.dart';

/// Message Bubble Component
/// Displays individual chat messages - stateless and dumb
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: message.isMe ? 64 : 12,
          right: message.isMe ? 12 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: message.isMe
              ? const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: message.isMe ? null : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: message.isMe
                  ? const Color(0xFF4A90E2).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= MESSAGE TEXT =================
            Text(
              message.message,
              style: TextStyle(
                color: message.isMe ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 6),

            // ================= TIME + STATUS =================
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.time),
                  style: TextStyle(
                    color: message.isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format timestamp
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Today - show time only
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      return DateFormat('EEE HH:mm').format(time);
    } else {
      // Older - show date
      return DateFormat('MMM dd, HH:mm').format(time);
    }
  }

  Widget _buildStatusIcon(String status) {
    Color color = Colors.grey;
    IconData icon = Icons.check;

    switch (status) {
      case 'sent':
        icon = Icons.check;
        color = Colors.grey;
        break;

      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;

      case 'read':
        icon = Icons.done_all;
        color = Colors.blue; // ✅ read = blue ticks
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
