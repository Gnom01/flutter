import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class ClientService {
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

  final AuthService _authService = AuthService();

  // Get all clients
  Future<Map<String, dynamic>> getClients() async {
    try {
      final token = await _authService.getToken();
      print(token);
      if (token == null) {
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/clients'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('🟢 [AUTH] Response status getClients: ${response.statusCode}');
        print('🟢 [AUTH] Response body getClients: ${data}');
        // Check for different response structures
        var clientsList = [];
        if (data['clients'] != null) {
          clientsList = data['clients'];
        } else if (data['data'] != null) {
          clientsList = data['data'];
        } else if (data is List) {
          clientsList = data;
        }

        return {'success': true, 'clients': clientsList};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {'success': false, 'message': 'Błąd pobierania danych'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Update client
  Future<Map<String, dynamic>> updateClient(
    int clientId,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _authService.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/clients/$clientId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'client': responseData['client'] ?? responseData,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {'success': false, 'message': 'Błąd aktualizacji danych'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }
}
