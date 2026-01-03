import 'package:chat_app/models/friend_model_new.dart';
import 'package:get/get.dart';
import '../models/friend_request_model.dart';
import '../models/sent_request_model.dart';
import '../models/pagination_model.dart';
import '../services/api_client.dart';
import '../services/db_helper.dart';

/// Friends Controller
/// Manages friends list and search - 100% business logic
class FriendsController extends GetxController {
  // Services`
  final ApiClient _apiClient = ApiClient();
  final DBHelper _dbHelper = DBHelper();

  // Observable state
  final RxList<FriendModel> friends = <FriendModel>[].obs;
  final RxList<FriendRequestModel> pendingRequests = <FriendRequestModel>[].obs;
  final RxList<SentRequestModel> sentRequests = <SentRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRequestsLoading = false.obs;
  final RxBool isSentRequestsLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Pagination state
  final Rx<PaginationModel?> pagination = Rx<PaginationModel?>(null);
  final RxInt currentPage = 1.obs;
  final RxInt pageLimit = 20.obs;

  // Loading states for individual actions
  final RxMap<String, bool> actionLoading = <String, bool>{}.obs;
  final RxMap<String, bool> acceptLoading = <String, bool>{}.obs;
  final RxMap<String, bool> rejectLoading = <String, bool>{}.obs;
  final RxMap<String, bool> cancelLoading = <String, bool>{}.obs;

  /// Check if an action is loading for a specific friend
  bool isActionLoading(String friendId) {
    return actionLoading[friendId] ?? false;
  }

  /// Check if accept action is loading for a specific request
  bool isAcceptLoading(String requestId) {
    return acceptLoading[requestId] ?? false;
  }

  bool isRemoveLoading(String requestId) {
    return acceptLoading[requestId] ?? false;
  }

  /// Check if reject action is loading for a specific request
  bool isRejectLoading(String requestId) {
    return rejectLoading[requestId] ?? false;
  }

  /// Check if cancel action is loading for a specific sent request
  bool isCancelLoading(String requestId) {
    return cancelLoading[requestId] ?? false;
  }

  /// Set loading state for a specific friend action
  void setActionLoading(String friendId, bool loading) {
    actionLoading[friendId] = loading;
  }

  /// Set loading state for accept action
  void setAcceptLoading(String requestId, bool loading) {
    acceptLoading[requestId] = loading;
  }

  /// Set loading state for reject action
  void setRejectLoading(String requestId, bool loading) {
    rejectLoading[requestId] = loading;
  }

  /// Set loading state for cancel action
  void setCancelLoading(String requestId, bool loading) {
    cancelLoading[requestId] = loading;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  /// Initialize controller with token
  Future<void> _initializeController() async {
    try {
      // Get and set auth token in API client
      final token = await getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
        print('✅ Auth token set in FriendsController');
      }

      // Load data
      await getAllUsers();
      await getPendingRequests();
      await getSentRequests();
    } catch (e) {
      print('❌ Error initializing FriendsController: $e');
    }
  }

  /// Get access token from SQLite
  Future<String?> getAccessToken() async {
    try {
      final token = await _dbHelper.getAccessToken();
      if (token == null) {
        errorMessage.value = 'No access token found. Please login again.';
      }
      return token;
    } catch (e) {
      errorMessage.value = 'Error retrieving access token';
      print('❌ Error getting access token: $e');
      return null;
    }
  }

  // Get Friends List
  Future<void> getFriends() async {
     try {
      friends.clear();
      // Reset error
      errorMessage.value = '';
      isLoading.value = true;

      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        isLoading.value = false;
        return;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API with pagination parameters
      final response = await _apiClient.getRequest(
        '/friends',
        queryParameters: {'page': currentPage.value, 'limit': pageLimit.value},
        headers: {'Authorization': 'Bearer $token'},
      );

      // Parse response - New structure with data array and pagination
      if (response['data'] != null) {
        final dataList = (response['data']['data'] as List)
            .map((json) => FriendModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final paginationData = response['pagination'];
        print(dataList);

        if (dataList.isNotEmpty) {
          if (currentPage.value == 1) {
            friends.value = dataList;
          } else {
            friends.addAll(dataList);
          }

          // Parse pagination
          if (paginationData != null) {
            pagination.value = PaginationModel.fromJson(
              paginationData as Map<String, dynamic>,
            );
          }

          print('✅ Friends loaded: ${friends.length}');
        } else {
          friends.value = [];
          print('⚠️ No data in response');
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load friends';
        friends.value = [];
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      print('❌ Error getting friends: $e');
    }
  }

  /// Get Users list
  Future<void> getAllUsers() async {
    try {
      friends.clear();
      // Reset error
      errorMessage.value = '';
      isLoading.value = true;

      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        isLoading.value = false;
        return;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API with pagination parameters
      final response = await _apiClient.getRequest(
        '/friends/all',
        queryParameters: {'page': currentPage.value, 'limit': pageLimit.value},
        headers: {'Authorization': 'Bearer $token'},
      );

      // Parse response - New structure with data array and pagination
      if (response['data'] != null) {
        final dataList = (response['data']['data'] as List)
            .map((json) => FriendModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final paginationData = response['pagination'];
        print(dataList);

        if (dataList.isNotEmpty) {
          if (currentPage.value == 1) {
            friends.value = dataList;
          } else {
            friends.addAll(dataList);
          }

          // Parse pagination
          if (paginationData != null) {
            pagination.value = PaginationModel.fromJson(
              paginationData as Map<String, dynamic>,
            );
          }

          print('✅ Friends loaded: ${friends.length}');
        } else {
          friends.value = [];
          print('⚠️ No data in response');
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load friends';
        friends.value = [];
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      print('❌ Error getting friends: $e');
    }
  }

  /// Search friends
  Future<void> searchFriends(String query) async {
    try {
      // Update search query
      searchQuery.value = query;

      // If query is empty, get all friends
      if (query.trim().isEmpty) {
        await getAllUsers();
        return;
      }

      // Don't search if query length < 2
      if (query.trim().length < 2) {
        return;
      }

      // Reset error
      errorMessage.value = '';
      isLoading.value = true;

      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        isLoading.value = false;
        return;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call search API with query parameter
      final response = await _apiClient.getRequest(
        '/friends/search',
        queryParameters: {'query': query.trim()},
        headers: {'Authorization': 'Bearer $token'},
      );

      // Parse response - API returns 'users' not 'friends' for search
      if (response['success'] == true && response['data'] != null) {
        final usersData = response['data']['users'];
        if (usersData != null && usersData is List) {
          friends.value = usersData
              .map((json) => FriendModel.fromJson(json as Map<String, dynamic>))
              .toList();

          print('✅ Search results: ${friends.length}');
        } else {
          friends.value = [];
          errorMessage.value = 'No friends found';
          print('⚠️ No users data in search response');
        }
      } else {
        errorMessage.value = response['message'] ?? 'No friends found';
        friends.value = [];
      }

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      friends.value = [];
      print('❌ Error searching friends: $e');
    }
  }

  /// Refresh friends list
  Future<void> refreshAllUsers() async {
    searchQuery.value = '';
    currentPage.value = 1;
    await getAllUsers();
  }

  Future<void> refreshFriends() async {
    searchQuery.value = '';
    currentPage.value = 1;
    await getFriends();
  }

  

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    getAllUsers();
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (pagination.value?.hasNextPage == true && !isLoading.value) {
      currentPage.value++;
      await getAllUsers();
    }
  }

  /// Load previous page
  Future<void> loadPreviousPage() async {
    if (pagination.value?.hasPrevPage == true &&
        !isLoading.value &&
        currentPage.value > 1) {
      currentPage.value--;
      await getAllUsers();
    }
  }

  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page > 0 &&
        page <= (pagination.value?.totalPages ?? 1) &&
        !isLoading.value) {
      currentPage.value = page;
      await getAllUsers();
    }
  }

  /// Get pending friend requests
  Future<void> getPendingRequests() async {
    try {
      // Reset error
      errorMessage.value = '';
      isRequestsLoading.value = true;

      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        isRequestsLoading.value = false;
        return;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API
      final response = await _apiClient.getRequest(
        '/friends/requests/pending',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Parse response
      if (response['success'] == true && response['data'] != null) {
        final requestsData = response['data']['requests'];
        if (requestsData != null && requestsData is List) {
          pendingRequests.value = requestsData
              .map(
                (json) =>
                    FriendRequestModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          print('✅ Pending requests loaded: ${pendingRequests.length}');
        } else {
          pendingRequests.value = [];
          print('⚠️ No pending requests data in response');
        }
      } else {
        pendingRequests.value = [];
      }

      isRequestsLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isRequestsLoading.value = false;
      print('❌ Error getting pending requests: $e');
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    setAcceptLoading(requestId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setAcceptLoading(requestId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API - PUT request to accept friend request
      final response = await _apiClient.putRequest(
        '/friends/accept/$requestId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Friend request accepted');

        // Refresh lists
        await getAllUsers();
        await getPendingRequests();

        Get.snackbar(
          'Success',
          'Friend request accepted',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setAcceptLoading(requestId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to accept request';
        setAcceptLoading(requestId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error accepting friend request: $e');
      setAcceptLoading(requestId, false);
      return false;
    }
  }

  /// Remove friend or reject request
  Future<bool> removeFriend(String friendId) async {
    setRejectLoading(friendId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setRejectLoading(friendId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API
      final response = await _apiClient.deleteRequest(
        '/friends/reject/$friendId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Friend removed');

        // Refresh lists
        await getAllUsers();
        await getPendingRequests();

        Get.snackbar(
          'Success',
          'Request rejected',
          snackPosition: SnackPosition.TOP,

          duration: const Duration(seconds: 2),
        );

        setRejectLoading(friendId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to remove friend';
        setRejectLoading(friendId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error removing friend: $e');
      setRejectLoading(friendId, false);
      return false;
    }
  }

  /// Send friend request (for search results)
  Future<bool> sendFriendRequest(String userId) async {
    setActionLoading(userId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setActionLoading(userId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API
      final response = await _apiClient.postRequest(
        '/friends/add',
        data: {'recipientId': userId},
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Friend request sent');

        // Refresh friends list
        await getAllUsers();
        await getSentRequests();

        Get.snackbar(
          'Success',
          'Friend request sent',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(userId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send request';

        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(userId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error sending friend request: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      setActionLoading(userId, false);
      return false;
    }
  }

  /// Add friend (for friends list)
  Future<bool> addFriend(String recipientId) async {
    setActionLoading(recipientId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setActionLoading(recipientId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API with recipientId in body
      final response = await _apiClient.postRequest(
        '/friends/add',
        data: {'recipientId': recipientId},
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Friend request sent');

        // Refresh friends list
        await getAllUsers();

        Get.snackbar(
          'Success',
          response['message'] ?? 'Friend request sent',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(recipientId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send request';

        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(recipientId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error adding friend: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      setActionLoading(recipientId, false);
      return false;
    }
  }

  /// Cancel friend request
  Future<bool> cancelFriendRequest(String userId) async {
    setActionLoading(userId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setActionLoading(userId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API to cancel friend request
      final response = await _apiClient.deleteRequest(
        '/friends/cancel/$userId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Friend request cancelled');

        // Refresh friends list
        await getSentRequests();

        Get.snackbar(
          'Success',
          'Friend request cancelled',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(userId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to cancel request';

        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setActionLoading(userId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error cancelling friend request: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      setActionLoading(userId, false);
      return false;
    }
  }

  /// Get sent friend requests
  Future<void> getSentRequests() async {
    try {
      // Reset error
      errorMessage.value = '';
      isSentRequestsLoading.value = true;

      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        isSentRequestsLoading.value = false;
        return;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API
      final response = await _apiClient.getRequest(
        '/friends/requests/sent',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Parse response
      if (response['success'] == true && response['data'] != null) {
        final requestsData = response['data']['requests'];
        if (requestsData != null && requestsData is List) {
          sentRequests.value = requestsData
              .map(
                (json) =>
                    SentRequestModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

          print('✅ Sent requests loaded: ${sentRequests.length}');
        } else {
          sentRequests.value = [];
          print('⚠️ No sent requests data in response');
        }
      } else {
        sentRequests.value = [];
      }

      isSentRequestsLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isSentRequestsLoading.value = false;
      print('❌ Error getting sent requests: $e');
    }
  }

  /// Cancel sent friend request
  Future<bool> cancelSentRequest(String requestId) async {
    setCancelLoading(requestId, true);
    try {
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        setCancelLoading(requestId, false);
        return false;
      }

      // Ensure token is set in API client
      _apiClient.setAuthToken(token);

      // Call API to remove friend (using recipient's ID)
      final response = await _apiClient.deleteRequest(
        '/friends/reject/$requestId',
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check response
      if (response['success'] == true) {
        print('✅ Sent request cancelled');

        // Remove from local list
        sentRequests.removeWhere((req) => req.recipient.id == requestId);

        Get.snackbar(
          'Success',
          'Friend request cancelled',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setCancelLoading(requestId, false);
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to cancel request';

        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        setCancelLoading(requestId, false);
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error cancelling sent request: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      setCancelLoading(requestId, false);
      return false;
    }
  }
}
