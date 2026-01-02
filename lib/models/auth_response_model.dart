import 'user_model.dart';

/// Auth Response Model
/// Represents the response from authentication endpoints (signup/login)
class AuthResponseModel {
  final bool success;
  final String message;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  /// Create AuthResponseModel from JSON (API response)
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] as Map<String, dynamic>?;

    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: data != null && data['user'] != null
          ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      accessToken: data?['accessToken'] as String?,
      refreshToken: data?['refreshToken'] as String?,
    );
  }

  /// Convert AuthResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'user': user?.toJson(),
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      },
    };
  }

  /// Create a copy of AuthResponseModel with updated fields
  AuthResponseModel copyWith({
    bool? success,
    String? message,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  @override
  String toString() {
    return 'AuthResponseModel(success: $success, message: $message, user: $user, hasAccessToken: ${accessToken != null}, hasRefreshToken: ${refreshToken != null})';
  }
}
