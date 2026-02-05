import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Getter to determine the base URL based on environment
  static String get baseUrl {
    // Check if running in debug mode (local development)
    if (kDebugMode) {
      // For Android emulator, use 10.0.2.2 to access host machine's localhost
      // For iOS simulator or web, use localhost
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      } else if (Platform.isIOS) {
        return 'http://localhost:8080';
      }
    }
    
    // For production/release builds or when not in debug mode
    return 'https://panelklienta.egurrola.com';
  }
  
  // Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));
        
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Nieprawidłowy email lub hasło'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Błąd połączenia: ${e.toString()}'
      };
    }
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
}
