import 'lib/models/user_model.dart';
import 'lib/services/db_helper.dart';
import 'lib/controllers/auth_controller.dart';
import 'lib/controllers/home_controller.dart';

/// Simple test to verify status management
void main() async {
  print('🧪 Testing status management fix...');
  
  // Create a test user
  final testUser = UserModel(
    id: 'test_user_123',
    username: 'testuser',
    email: 'test@example.com',
    status: 'offline', // Initial status
  );
  
  print('📋 Initial user: ${testUser.username}, status: ${testUser.status}');
  
  // Test status update logic
  final updatedUser = testUser.copyWith(status: 'online');
  print('✅ Updated user: ${updatedUser.username}, status: ${updatedUser.status}');
  
  // Verify the status changed
  if (updatedUser.status == 'online') {
    print('🎉 Status update logic works correctly!');
  } else {
    print('❌ Status update logic failed');
  }
  
  print('🏁 Test completed');
}
