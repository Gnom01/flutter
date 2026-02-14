import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/user_consents.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  // Fetch user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/user/profile';
      print('🔵 [USER] Fetching profile from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟢 [USER] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final profile = UserProfile.fromJson(data['user']);
          return {'success': true, 'profile': profile};
        } else {
          return {'success': false, 'message': 'Błąd przetwarzania danych'};
        }
      } else if (response.statusCode == 401) {
        AuthService.logoutAndRedirect();
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania profilu: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Fetch user consents
  Future<Map<String, dynamic>> getUserConsents() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/user/consents';
      print('🔵 [USER] Fetching consents from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟢 [USER] Consents response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['consents'] != null) {
          final consents = UserConsents.fromJson(data['consents']);
          return {'success': true, 'consents': consents};
        } else {
          return {
            'success': false,
            'message': 'Błąd przetwarzania danych zgód',
          };
        }
      } else if (response.statusCode == 401) {
        AuthService.logoutAndRedirect();
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania zgód: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Consents Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }
}
