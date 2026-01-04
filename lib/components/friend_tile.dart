import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/friend_model_new.dart';
import '../controllers/friends_controller.dart';

/// Friend Tile Component
/// Reusable friend list item - stateless and dumb
class FriendTile extends StatelessWidget {
  final FriendModel friend;
  final VoidCallback onTap;
  final VoidCallback? onAddFriend;
  final VoidCallback? onCancelRequest;
  final bool showAddButton;
  final bool canUserChat;

  const FriendTile({
    super.key,
    required this.friend,
    required this.onTap,
    this.onAddFriend,
    this.onCancelRequest,
    this.showAddButton = false,
    this.canUserChat = false,
  });

  FriendsController get controller => Get.find<FriendsController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 24, // Account for container margins
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: friend.status == "online"
                        ? [const Color(0xFF4A90E2), const Color(0xFF6C63FF)]
                        : [Colors.grey[400]!, Colors.grey[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (friend.status == "online"
                                  ? const Color(0xFF4A90E2)
                                  : Colors.grey)
                              .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 22,
                  backgroundImage:
                      friend.avatar != null && friend.avatar!.isNotEmpty
                      ? NetworkImage(friend.avatar!)
                      : null,
                  child: friend.avatar == null || friend.avatar!.isEmpty
                      ? Text(
                          friend.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: friend.status == "online"
                        ? const Color(0xFF43A047)
                        : Colors.grey[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (friend.status == "online"
                                    ? const Color(0xFF43A047)
                                    : Colors.grey)
                                .withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            friend.username,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          trailing: _buildTrailingWidget(),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildTrailingWidget() {
    return Obx(() {
      final isLoading = controller.isActionLoading(friend.id);

      // // Show cancel button if request is already sent
      // if (friend.friendshipStatus == 'request_sent') {
      //   return Container(
      //     width: 36,
      //     height: 36,
      //     decoration: BoxDecoration(
      //       color: Colors.orange.withOpacity(0.1),
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     child: isLoading
      //         ? const Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: CircularProgressIndicator(
      //               strokeWidth: 2,
      //               valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      //             ),
      //           )
      //         : IconButton(
      //             padding: EdgeInsets.zero,
      //             iconSize: 20,
      //             icon: const Icon(Icons.cancel_outlined, color: Colors.orange),
      //             onPressed: isLoading ? null : onCancelRequest,
      //           ),
      //   );
      // }

      // Show add button for search results or non-friends
      if (showAddButton &&
          friend.friendshipStatus != 'friends' &&
          friend.friendshipStatus != 'request_sent') {
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF6C63FF)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A90E2).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  onPressed: isLoading ? null : onAddFriend,
                ),
        );
      }

      // Default: show message button for friends
      if (canUserChat || friend.friendshipStatus == 'friends') {
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            iconSize: 20,
            icon: const Icon(Icons.message_outlined, color: Color(0xFF4A90E2)),
            onPressed: () {
              // Navigate to chat screen with friend data
              Get.toNamed(
                '/chat',
                arguments: {
                  'friendId': friend.id,
                  'friendName': friend.username,
                },
              );
            },
          ),
        );
      }
      return SizedBox.shrink();
    });
  }
}
