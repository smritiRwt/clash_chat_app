import 'package:chat_app/screens/intro_slider.dart';
import 'package:chat_app/screens/signup_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/screens/home/home_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/theme/app_theme.dart';
import 'package:chat_app/services/db_helper.dart';
import 'package:chat_app/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool isLoggedIn = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dbHelper = DBHelper();
    final user = await dbHelper.getLoggedInUser();

    if (user != null) {
      print('✅ User found in DB: ${user.username}');

      // Set auth token in API client
      final token = await dbHelper.getAccessToken();
      if (token != null) {
        final apiClient = ApiClient();
        apiClient.setAuthToken(token);
        print('✅ Auth token set in API client on app start');
      }

      isLoggedIn = true;
    } else {
      isLoggedIn = false;
    }
  } catch (e) {
    print('❌ Error checking user: $e');
    isLoggedIn = false;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      // builder: (context, child) {
      //   return SafeArea(
      //     top: false,
      //     bottom: true,
      //     left: true,
      //     right: true,
      //     child: Scaffold(
      //       body: child,
      //     ),
      //   );
      // },

      // 🌈 App Theme
      theme: AppTheme.lightTheme,

      // 🚀 Initial Route
      initialRoute: isLoggedIn ? '/home' : '/intro_slider',
      // 🧭 Pages
      getPages: [
        GetPage(name: '/intro_slider', page: () => const IntroSlider()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/chat', page: () => const ChatScreen()),
      ],
    );
  }
}
