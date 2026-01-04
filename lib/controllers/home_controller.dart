import 'dart:developer';

import 'package:chat_app/services/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat_app/services/db_helper.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/home/chat_tab.dart';
import '../screens/home/friends_tab.dart';
import '../screens/home/profile_tab.dart';
import 'auth_controller.dart';

/// Home Controller
/// Manages tab navigation and home screen state
class HomeController extends GetxController with WidgetsBindingObserver {
  // Current tab index
  final RxInt currentIndex = 0.obs;
  final DBHelper _dbHelper = DBHelper();
  SocketService socketService = SocketService();

  // Flag to track if token refresh has been attempted
  bool _hasRefreshedToken = false;

  // List of tab widgets
  final List<Widget> _tabs = [
    const ChatTab(),
    const FriendsTab(),
    const ProfileTab(),
  ];

  // Auth controller reference
  late AuthController _authController;

  @override
  void onInit() async {
    super.onInit();
    
    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Get or create AuthController
    try {
      _authController = Get.find<AuthController>();
    } catch (e) {
      _authController = Get.put(AuthController());
    }
    
    await createSocketConnection();
    _refreshTokenOnLoad();
    
    // Initialize user status
    _initializeUserStatus();
  }

  /// Refresh token when HomePage loads (only once per app launch)
  Future<void> _refreshTokenOnLoad() async {
    // Prevent duplicate refresh calls
    if (_hasRefreshedToken) {
      print('⚠️ Token already refreshed in this session');
      return;
    }

    _hasRefreshedToken = true;

    try {
      // Always attempt to refresh token - checkAndRefreshToken will handle validation
      print('🔄 Attempting to refresh token on HomePage load...');
      await _authController.checkAndRefreshToken();
    } catch (e) {
      print('❌ Error during token refresh on HomePage load: $e');
    }
  }

  /// Get current page widget
  Widget get currentPage => _tabs[currentIndex.value];

  /// Change tab
  void changeTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      currentIndex.value = index;
    }
  }

  //make socket connection
  Future<void> createSocketConnection() async {
    try {
      // Get access token from DB
      final accessToken = await _dbHelper.getAccessToken();
      if (accessToken != null) {
        // Set up socket listeners before connecting
        _setupSocketListeners();
        socketService.connect(accessToken);
      }
    } catch (e) {
      log('❌ Error creating WebSocket connection: $e');
    }
  }

  /// Setup socket listeners for status updates
  void _setupSocketListeners() {
    // Listen for socket connection
    socketService.onConnected = () {
      print('✅ Socket connected - updating user status to online');
      _updateUserStatus('online');
    };

    // Listen for socket disconnection
    socketService.onDisconnected = () {
      print('❌ Socket disconnected - updating user status to offline');
      _updateUserStatus('offline');
    };

    // Listen for user online events (for other users)
    socketService.onUserOnline = (userId) {
      print('🟢 User $userId is now online');
      // Here you could update a friends list if needed
    };

    // Listen for user offline events (for other users)
    socketService.onUserOffline = (userId) {
      print('⚫ User $userId is now offline');
      // Here you could update a friends list if needed
    };
  }

  /// Update current user status in database and UI
  Future<void> _updateUserStatus(String status) async {
    try {
      final currentUser = _authController.currentUser.value;
      print('🔍 Current user: ${currentUser?.username}, current status: ${currentUser?.status}, new status: $status');
      
      if (currentUser != null && currentUser.status != status) {
        // Create updated user model
        final updatedUser = currentUser.copyWith(status: status);
        
        // Update in database
        await _dbHelper.updateUser(updatedUser);
        
        // Update in controller (this will trigger UI update)
        _authController.currentUser.value = updatedUser;
        
        print('✅ User status updated to: $status for user: ${updatedUser.username}');
      } else {
        print('⏭️ Status unchanged or user null');
      }
    } catch (e) {
      print('❌ Error updating user status: $e');
    }
  }

  /// Initialize user status when app starts
  void _initializeUserStatus() {
    // Set initial status to online since the app just started
    // The actual socket connection will update this properly
    _updateUserStatus('online');
  }

  /// Get tab count
  int get tabCount => _tabs.length;

  @override
  void onClose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Clean up socket callbacks
    socketService.clearCallbacks();
    socketService.disconnect();
    super.onClose();
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App resumed - updating status to online');
        _updateUserStatus('online');
        break;
      case AppLifecycleState.paused:
        print('⏸️ App paused - updating status to offline');
        _updateUserStatus('offline');
        break;
      case AppLifecycleState.detached:
        print('🔌 App detached - updating status to offline');
        _updateUserStatus('offline');
        break;
      case AppLifecycleState.inactive:
        // App is inactive but still visible
        break;
      case AppLifecycleState.hidden:
        print('🙈 App hidden - updating status to offline');
        _updateUserStatus('offline');
        break;
    }
  }
}
