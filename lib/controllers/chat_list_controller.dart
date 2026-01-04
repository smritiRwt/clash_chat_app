import 'package:get/get.dart';
import '../models/chat_list_model.dart';
import '../services/api_client.dart';
import '../services/db_helper.dart';

class ChatListController extends GetxController {
  final ApiClient _apiClient = ApiClient();
  final DBHelper _dbHelper = DBHelper();
  
  // Observable state
  final RxList<ChatListModel> chats = <ChatListModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = false.obs;
  final RxInt total = 0.obs;
  
  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt limit = 20.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadChats();
  }
  
  /// Load chats from API
  Future<void> loadChats({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        chats.clear();
      }
      
      errorMessage.value = '';
      isLoading.value = true;
      
      // Get access token
      final token = await getAccessToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        isLoading.value = false;
        return;
      }
      
      // Set auth token
      _apiClient.setAuthToken(token);
      
      // Make API request
      final response = await _apiClient.getRequest(
        '/chats',
        queryParameters: {
          'limit': limit.value,
          'skip': currentPage.value * limit.value,
        },
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response['success'] == true) {
        try {
          final chatResponse = ChatListResponse.fromJson(response);
          
          if (refresh) {
            chats.value = chatResponse.data.chats;
          } else {
            chats.addAll(chatResponse.data.chats);
          }
          
          total.value = chatResponse.data.total;
          hasMore.value = chatResponse.data.hasMore;
          currentPage.value++;
          
          print('✅ Chats loaded: ${chats.length}');
        } catch (parseError) {
          errorMessage.value = 'Failed to parse chat data: $parseError';
          print('❌ Parse error: $parseError');
          print('❌ Response data: $response');
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load chats';
        print('❌ Failed to load chats: ${response['message']}');
      }
      
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error loading chats: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Refresh chats list
  Future<void> refreshChats() async {
    await loadChats(refresh: true);
  }
  
  /// Load more chats (pagination)
  Future<void> loadMoreChats() async {
    if (!isLoading.value && hasMore.value) {
      await loadChats();
    }
  }
  
  /// Navigate to chat screen
  void navigateToChat(ChatListModel chat) {
    Get.toNamed(
      '/chat',
      arguments: {
        'friendId': chat.friendId,
        'friendName': chat.friend.username,
        'friendAvatar': chat.friend.avatar,
      },
    );
  }
  
  /// Get access token from SQLite
  Future<String?> getAccessToken() async {
    try {
      final token = await _dbHelper.getAccessToken();
      if (token == null) {
        print('❌ No access token found in storage');
        return null;
      }
      return token;
    } catch (e) {
      print('❌ Error retrieving access token: $e');
      return null;
    }
  }
  
  /// Format message time
  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Today - show time only
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      // Older - show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
