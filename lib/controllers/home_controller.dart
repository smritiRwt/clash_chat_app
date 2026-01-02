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
class HomeController extends GetxController {
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

  @override
  void onInit() async {
    super.onInit();
    await createSocketConnection();
    _refreshTokenOnLoad();
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
      // Get or create AuthController
      AuthController authController;
      try {
        authController = Get.find<AuthController>();
      } catch (e) {
        authController = Get.put(AuthController());
      }

      // Always attempt to refresh token - checkAndRefreshToken will handle validation
      print('🔄 Attempting to refresh token on HomePage load...');
      await authController.checkAndRefreshToken();
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
        socketService.connect(accessToken);
      }
    } catch (e) {
      log('❌ Error creating WebSocket connection: $e');
    }
  }

  /// Get tab count
  int get tabCount => _tabs.length;
}
