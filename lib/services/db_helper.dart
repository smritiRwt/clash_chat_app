import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user_model.dart';

/// Database Helper Service using SQLite
/// Singleton pattern for database operations
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  static Database? _database;

  DBHelper._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'chat_app.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        avatar TEXT,
        status TEXT DEFAULT 'offline',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create auth_tokens table
    await db.execute('''
      CREATE TABLE auth_tokens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        access_token TEXT NOT NULL,
        refresh_token TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    print('✅ Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Insert user into database
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await database;
      final result = await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ User inserted successfully: ${user.username}');
      return result;
    } catch (e) {
      print('❌ Error inserting user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      return null;
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return UserModel.fromMap(maps.first);
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// Update user
  Future<int> updateUser(UserModel user) async {
    try {
      final db = await database;
      final result = await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      print('✅ User updated successfully: ${user.username}');
      return result;
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user
  Future<int> deleteUser(String userId) async {
    try {
      final db = await database;
      final result = await db.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      print('✅ User deleted successfully');
      return result;
    } catch (e) {
      print('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // ==================== AUTH TOKEN OPERATIONS ====================

  /// Save auth tokens
  Future<int> saveAuthTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final db = await database;

      // Delete existing tokens for this user
      await db.delete('auth_tokens', where: 'user_id = ?', whereArgs: [userId]);

      // Insert new tokens
      final result = await db.insert('auth_tokens', {
        'user_id': userId,
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      print('✅ Auth tokens saved successfully');
      return result;
    } catch (e) {
      print('❌ Error saving auth tokens: $e');
      rethrow;
    }
  }

  /// Get auth tokens by user ID
  Future<Map<String, dynamic>?> getAuthTokens(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'auth_tokens',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return maps.first;
    } catch (e) {
      print('❌ Error getting auth tokens: $e');
      return null;
    }
  }

  /// Get current user's access token
  Future<String?> getAccessToken() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'auth_tokens',
        columns: ['access_token'],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return maps.first['access_token'] as String?;
    } catch (e) {
      print('❌ Error getting access token: $e');
      return null;
    }
  }

  /// Get current user's refresh token
  Future<String?> getRefreshToken() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'auth_tokens',
        columns: ['refresh_token'],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return maps.first['refresh_token'] as String?;
    } catch (e) {
      print('❌ Error getting refresh token: $e');
      return null;
    }
  }

  /// Update auth tokens
  Future<int> updateAuthTokens({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final db = await database;
      final result = await db.update(
        'auth_tokens',
        {
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('✅ Auth tokens updated successfully');
      return result;
    } catch (e) {
      print('❌ Error updating auth tokens: $e');
      rethrow;
    }
  }

  /// Delete auth tokens
  Future<int> deleteAuthTokens(String userId) async {
    try {
      final db = await database;
      final result = await db.delete(
        'auth_tokens',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('✅ Auth tokens deleted successfully');
      return result;
    } catch (e) {
      print('❌ Error deleting auth tokens: $e');
      rethrow;
    }
  }

  /// Clear all auth tokens (logout all sessions)
  Future<int> clearAllAuthTokens() async {
    try {
      final db = await database;
      final result = await db.delete('auth_tokens');
      print('✅ All auth tokens cleared successfully');
      return result;
    } catch (e) {
      print('❌ Error clearing all auth tokens: $e');
      rethrow;
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Check if user exists
  Future<bool> userExists(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('❌ Error checking if user exists: $e');
      return false;
    }
  }

  /// Get logged in user (user with valid token)
  Future<UserModel?> getLoggedInUser() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> tokenMaps = await db.query(
        'auth_tokens',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (tokenMaps.isEmpty) return null;

      final userId = tokenMaps.first['user_id'] as String;
      return await getUserById(userId);
    } catch (e) {
      print('❌ Error getting logged in user: $e');
      return null;
    }
  }

  /// Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('auth_tokens');
      await db.delete('users');
      print('✅ All data cleared successfully');
    } catch (e) {
      print('❌ Error clearing all data: $e');
      rethrow;
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('✅ Database closed successfully');
  }
}
