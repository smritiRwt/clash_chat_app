import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/friends_controller.dart';
import '../../components/friend_tile.dart';
import '../../components/pending_request_tile.dart';
import '../../components/sent_request_tile.dart';
import '../../components/skeleton_loader.dart';

/// Friends Tab
/// Displays list of friends - 100% dumb UI
class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  FriendsController get controller {
    try {
      return Get.find<FriendsController>();
    } catch (e) {
      return Get.put(FriendsController());
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to refresh data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Tab animation completed
        if(_tabController.index == 0) {
          // Friends tab selected - refresh friends
          controller.getFriends();
        } else if (_tabController.index == 1) {
          // All tab selected - refresh all
          controller.getAllUsers();
        } else if (_tabController.index == 2) {
          // Requests tab selected - refresh requests
          controller.getPendingRequests();
        } else if (_tabController.index == 3) {
          // Sent tab selected - refresh sent requests
          controller.getSentRequests();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchFriends(value),
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(
                        () => controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : const SizedBox.shrink(),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF4A90E2),
                  labelColor: const Color(0xFF4A90E2),
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: [
                    const Tab(text: 'Friends'),
                    const Tab(text: 'All Users'),
                    Tab(
                      child: Obx(
                        () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Requests'),
                            if (controller.pendingRequests.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  controller.pendingRequests.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: Obx(
                        () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Sent'),
                            if (controller.sentRequests.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  controller.sentRequests.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildFriendsTab(), _buildAllUsersTab(), _buildRequestsTab(), _buildSentTab()],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      // Show error as snackbar
      if (controller.errorMessage.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Error',
            controller.errorMessage.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
            icon: const Icon(Icons.error_outline, color: Colors.red),
          );
          controller.errorMessage.value = ''; // Clear error after showing
        });
      }

      // Loading state - show skeleton
      if (controller.isLoading.value && controller.friends.isEmpty) {
        return const FriendsListSkeleton();
      }

      // Empty state
      if (controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No friends found'
                    : 'No friends yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'Try a different search'
                    : 'Add friends to start chatting',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      // Friends list
      return RefreshIndicator(
        onRefresh: controller.refreshFriends,
        child: ListView.builder(
          itemCount: controller.friends.length,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            final isSearchResult = controller.searchQuery.value.isNotEmpty;

            return FriendTile(
              friend: friend,
              canUserChat: true,
              onTap: () {
                // TODO: View friend profile
              },
              showAddButton: false,
              // onAddFriend: isSearchResult
              //     ? () => controller.sendFriendRequest(friend.id)
              //     : () => controller.addFriend(friend.id),
              // onCancelRequest: () => controller.cancelFriendRequest(friend.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildAllUsersTab() {
    return Obx(() {
      // Show error as snackbar
      if (controller.errorMessage.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Error',
            controller.errorMessage.value,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
            icon: const Icon(Icons.error_outline, color: Colors.red),
          );
          controller.errorMessage.value = ''; // Clear error after showing
        });
      }

      // Loading state - show skeleton
      if (controller.isLoading.value && controller.friends.isEmpty) {
        return const FriendsListSkeleton();
      }

      // Empty state
      if (controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'No friends found'
                    : 'No friends yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'Try a different search'
                    : 'Add friends to start chatting',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      // Friends list
      return RefreshIndicator(
        onRefresh: controller.refreshAllUsers,
        child: ListView.builder(
          itemCount: controller.friends.length,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            final isSearchResult = controller.searchQuery.value.isNotEmpty;

            return FriendTile(
              friend: friend,
              onTap: () {
                // TODO: View friend profile
              },
              showAddButton: true,
              onAddFriend: isSearchResult
                  ? () => controller.sendFriendRequest(friend.id)
                  : () => controller.addFriend(friend.id),
              onCancelRequest: () => controller.cancelFriendRequest(friend.id),
            );
          },
        ),
      );
    });
  }
  
  Widget _buildRequestsTab() {
    return Obx(() {
      // Loading state - show skeleton
      if (controller.isRequestsLoading.value) {
        return const FriendsListSkeleton();
      }

      // Empty state
      if (controller.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No pending requests',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Friend requests will appear here',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      // Requests list
      return RefreshIndicator(
        onRefresh: controller.getPendingRequests,
        child: ListView.builder(
          itemCount: controller.pendingRequests.length,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (context, index) {
            final request = controller.pendingRequests[index];
            return PendingRequestTile(
              request: request,
              onAccept: () => controller.acceptFriendRequest(request.id),
              onReject: () => controller.removeFriend(request.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildSentTab() {
    return Obx(() {
      // Loading state - show skeleton
      if (controller.isSentRequestsLoading.value) {
        return const FriendsListSkeleton();
      }

      // Empty state
      if (controller.sentRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No sent requests',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent friend requests will appear here',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      // Sent requests list
      return RefreshIndicator(
        onRefresh: controller.getSentRequests,
        child: ListView.builder(
          itemCount: controller.sentRequests.length,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (context, index) {
            final request = controller.sentRequests[index];
            return SentRequestTile(
              request: request,
              onCancel: () => controller.cancelSentRequest(request.id),
            );
          },
        ),
      );
    });
  }
}
