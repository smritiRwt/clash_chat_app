import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/db_helper.dart';

/// Auth Controller
/// Handles authentication logic (signup, login, logout)
class AuthController extends GetxController {
  // Dependencies
  final ApiClient _apiClient = ApiClient();
  final DBHelper _dbHelper = DBHelper();
  final _formKey = GlobalKey<FormState>();

  // Text Controllers (owned by controller, not UI)
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // Form keys
  final signupFormKey = GlobalKey<FormState>();
  final loginFormKey = GlobalKey<FormState>();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshingToken = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadLoggedInUser();
  }

  /// Load logged in user from database
  Future<void> _loadLoggedInUser() async {
    try {
      final user = await _dbHelper.getLoggedInUser();
      if (user != null) {
        currentUser.value = user;

        // Set auth token in API client
        final accessToken = await _dbHelper.getAccessToken();
        if (accessToken != null) {
          _apiClient.setAuthToken(accessToken);
        }
      }
    } catch (e) {
      print('❌ Error loading logged in user: $e');
    }
  }

  /// Validate signup form
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Signup user
  Future<bool> signup() async {
    try {
      // Reset messages
      errorMessage.value = '';
      successMessage.value = '';
      isLoading.value = true;

      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Check if user already exists locally
      final userExists = await _dbHelper.userExists(email);
      if (userExists) {
        errorMessage.value = 'User already exists. Please login.';
        isLoading.value = false;
        return false;
      }

      // Make API call
      final response = await _apiClient.postRequest(
        '/auth/signup',
        data: {'username': username, 'email': email, 'password': password},
      );

      // Parse response
      final authResponse = AuthResponseModel.fromJson(response);

      if (authResponse.success && authResponse.user != null) {
        // Save user to database
        await _dbHelper.insertUser(authResponse.user!);

        // Save auth tokens
        if (authResponse.accessToken != null &&
            authResponse.refreshToken != null) {
          await _dbHelper.saveAuthTokens(
            userId: authResponse.user!.id,
            accessToken: authResponse.accessToken!,
            refreshToken: authResponse.refreshToken!,
          );

          // Set auth token in API client
          _apiClient.setAuthToken(authResponse.accessToken!);
        }

        // Update current user
        currentUser.value = authResponse.user;

        // Set success message
        successMessage.value = authResponse.message;

        // Stop loading BEFORE navigation
        isLoading.value = false;

        // Navigate to home screen after a brief delay to ensure UI updates complete
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAllNamed('/home');

        return true;
      } else {
        errorMessage.value = authResponse.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      print('❌ Signup error: $e');
      return false;
    }
  }

  /// Login user
  Future<bool> login() async {
    try {
      // Reset messages
      errorMessage.value = '';
      successMessage.value = '';
      isLoading.value = true;

      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text.trim();

      // Make API call
      final response = await _apiClient.postRequest(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Parse response
      final authResponse = AuthResponseModel.fromJson(response);

      if (authResponse.success && authResponse.user != null) {
        // Save user to database
        await _dbHelper.insertUser(authResponse.user!);

        // Save auth tokens
        if (authResponse.accessToken != null &&
            authResponse.refreshToken != null) {
          await _dbHelper.saveAuthTokens(
            userId: authResponse.user!.id,
            accessToken: authResponse.accessToken!,
            refreshToken: authResponse.refreshToken!,
          );

          // Set auth token in API client
          _apiClient.setAuthToken(authResponse.accessToken!);
        }

        // Update current user
        currentUser.value = authResponse.user;

        // Set success message
        successMessage.value = authResponse.message;

        // Stop loading BEFORE navigation
        isLoading.value = false;

        // Navigate to home screen after a brief delay to ensure UI updates complete
        await Future.delayed(const Duration(milliseconds: 100));
        Get.offAllNamed('/home');

        return true;
      } else {
        errorMessage.value = authResponse.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      print('❌ Login error: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Clear auth tokens from database
      if (currentUser.value != null) {
        await _dbHelper.deleteAuthTokens(currentUser.value!.id);
      }

      // Remove auth token from API client
      _apiClient.removeAuthToken();

      // Clear current user
      currentUser.value = null;

      // Clear messages
      errorMessage.value = '';
      successMessage.value = '';

      // Stop loading BEFORE navigation
      isLoading.value = false;

      // Navigate to login screen after a brief delay
      await Future.delayed(const Duration(milliseconds: 100));

      // Delete this controller instance so a fresh one is created on login screen
      // Get.delete<AuthController>();

      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Error logging out';
      isLoading.value = false;
      print('❌ Logout error: $e');
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Clear success message
  void clearSuccess() {
    successMessage.value = '';
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    try {
      // Prevent duplicate refresh calls
      if (isRefreshingToken.value) {
        print('⚠️ Token refresh already in progress');
        return false;
      }

      isRefreshingToken.value = true;

      // Get refresh token from database
      final refreshToken = await _dbHelper.getRefreshToken();
      if (refreshToken == null) {
        print('❌ No refresh token found');
        isRefreshingToken.value = false;
        return false;
      }

      print('🔄 Refreshing access token...');

      // Call refresh token API
      final response = await _apiClient.postRequest(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      // Parse response
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          // Update tokens in database
          final user = await _dbHelper.getLoggedInUser();
          if (user != null) {
            await _dbHelper.updateAuthTokens(
              userId: user.id,
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Update API client with new token
            _apiClient.setAuthToken(newAccessToken);

            print('✅ Token refreshed successfully');
            isRefreshingToken.value = false;
            return true;
          }
        }
      }

      print('❌ Failed to refresh token');
      isRefreshingToken.value = false;
      return false;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      isRefreshingToken.value = false;
      return false;
    }
  }

  /// Check and refresh token if needed (called on app start)
  Future<bool> checkAndRefreshToken() async {
    try {
      // Check if user is logged in by checking database directly
      final user = await _dbHelper.getLoggedInUser();
      if (user == null) {
        print('⚠️ No logged in user found in database');
        return false;
      }

      // Update currentUser if not already set
      if (currentUser.value == null) {
        currentUser.value = user;
      }

      // Check if refresh token exists
      final refreshToken = await _dbHelper.getRefreshToken();
      if (refreshToken == null) {
        print('⚠️ No refresh token found');
        return false;
      }

      print('✅ User logged in: ${user.username}, refreshing token...');

      // Refresh the token
      final success = await this.refreshToken();

      if (!success) {
        // Token refresh failed - clear tokens and redirect to login
        print('❌ Token refresh failed - logging out');
        await _dbHelper.deleteAuthTokens(user.id);
        _apiClient.removeAuthToken();
        currentUser.value = null;

        // Navigate to login
        Get.offAllNamed('/login');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking and refreshing token: $e');
      return false;
    }
  }

  @override
  void onClose() {
    // Dispose text controllers
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    // loginEmailController.dispose();
    // loginPasswordController.dispose();
    super.onClose();
  }

  /// Handle login
  Future<void> handleLogin() async {
    // Validate form
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    // Call controller login method - navigation handled in controller
    await login();
  }
}
