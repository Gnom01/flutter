import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ClientService {
  static const String baseUrl = 'https://panelklienta.egurrola.com';
  final AuthService _authService = AuthService();

  // Get all clients
  Future<Map<String, dynamic>> getClients() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Brak autoryzacji'
        };
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
        return {
          'success': true,
          'clients': data['clients'] ?? data
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.'
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania danych'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Błąd połączenia: ${e.toString()}'
      };
    }
  }

  // Update client
  Future<Map<String, dynamic>> updateClient(int clientId, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Brak autoryzacji'
        };
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
          'client': responseData['client'] ?? responseData
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.'
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd aktualizacji danych'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Błąd połączenia: ${e.toString()}'
      };
    }
  }
}
