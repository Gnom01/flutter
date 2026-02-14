import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/user.dart';
import '../screens/login_screen.dart';

class AuthService {
  static String get baseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'https://api.egurrola-app.pl';
      } else if (Platform.isIOS) {
        return 'https://api.egurrola-app.pl';
      }
    }

    return 'https://api.egurrola-app.pl';
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '$baseUrl/api/login';
      print('🔵 [AUTH] Attempting login to: $url');
      print('🔵 [AUTH] Email: $email');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'Email': email, 'Password': password}),
      );

      print('🟢 [AUTH] Response status: ${response.statusCode}');
      print('🟢 [AUTH] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse user data
        final user = User.fromJson(data['user']);

        // Save token and user
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(user.toJson()));

        print('✅ [AUTH] Login successful');
        print('✅ [AUTH] User roles: ${user.role}');
        return {'success': true, 'user': user, 'data': data};
      } else {
        print('❌ [AUTH] Login failed with status: ${response.statusCode}');
        return {'success': false, 'message': 'Nieprawidłowy email lub hasło'};
      }
    } catch (e, stackTrace) {
      print('🔴 [AUTH] Exception occurred: $e');
      print('🔴 [AUTH] Stack trace: $stackTrace');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  // Logout method
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Call logout endpoint to invalidate token on server
        await http.post(
          Uri.parse('$baseUrl/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Continue with local logout even if server call fails
      print('Logout API error: $e');
    } finally {
      // Always clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Global session expiry handler
  static Future<void> logoutAndRedirect() async {
    final authService = AuthService();
    await authService.logout();

    // Use the global navigator key to go to login screen
    final navigator = MyApp.navigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
