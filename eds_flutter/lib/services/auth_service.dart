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
        // return 'https://api.egurrola-app.pl';
        // docker
        // return 'http://10.0.2.2:8080';
        // lockal
        return 'http://10.0.2.2:8000';
      } else if (Platform.isIOS) {
        // return 'https://api.egurrola-app.pl';
        // docker
        // return 'http://localhost:8080';
        // lockal
        return 'http://localhost:8000';
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

  // ─── SMS OTP ──────────────────────────────────────────────────────────────

  /// Wysyła kod OTP na podany numer telefonu.
  Future<Map<String, dynamic>> sendSmsOtp(String phone) async {
    try {
      final url = '$baseUrl/api/sms/send';
      print('🔵 [AUTH] Sending OTP to: $url with phone: $phone');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );
      print('🟢 [AUTH] sendSmsOtp status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Błąd wysyłki SMS',
      };
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  /// Weryfikuje kod OTP.
  Future<Map<String, dynamic>> verifySmsOtp(String phone, String code) async {
    try {
      final url = '$baseUrl/api/sms/verify';
      print('🔵 [AUTH] Verifying OTP at: $url for phone: $phone');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      print('🟢 [AUTH] verifySmsOtp status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'otp_token': data['otp_token']};
      }
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Nieprawidłowy kod SMS',
      };
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // ─── Rejestracja ──────────────────────────────────────────────────────────

  /// Zakłada nowe konto po zweryfikowaniu OTP.
  Future<Map<String, dynamic>> registerAccount({
    required String phone,
    required String otpToken,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final url = '$baseUrl/api/register';
      print(
        '🔵 [AUTH] Registering account at: $url for email: $email, phone: $phone',
      );
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp_token': otpToken,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      );
      print('🟢 [AUTH] registerAccount status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Błąd rejestracji',
      };
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // ─── Reset hasła ──────────────────────────────────────────────────────────

  /// Inicjuje reset hasła – wysyła OTP na telefon.
  Future<Map<String, dynamic>> resetPasswordRequest(String phone) async {
    try {
      final url = '$baseUrl/api/password/reset';
      print('🔵 [AUTH] Password reset request at: $url for phone: $phone');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );
      print('🟢 [AUTH] resetPasswordRequest status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Nie znaleziono konta',
      };
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  /// Zatwierdza nowe hasło po weryfikacji OTP.
  Future<Map<String, dynamic>> resetPasswordConfirm({
    required String phone,
    required String otpToken,
    required String newPassword,
  }) async {
    try {
      final url = '$baseUrl/api/password/reset/confirm';
      print('🔵 [AUTH] Confirming password reset at: $url for phone: $phone');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp_token': otpToken,
          'password': newPassword,
        }),
      );
      print('🟢 [AUTH] resetPasswordConfirm status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final body = jsonDecode(response.body);
      return {
        'success': false,
        'message': body['message'] ?? 'Błąd zmiany hasła',
      };
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }
}
