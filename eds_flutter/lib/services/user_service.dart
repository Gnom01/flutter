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

  // Fetch payment schedule
  Future<Map<String, dynamic>> getPaymentSchedule() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/payments/schedule';
      print('🔵 [USER] Fetching payment schedule from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '🟢 [USER] Payment schedule response status: ${response.statusCode}',
      );
      print('📄 [USER] Payment schedule body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle nested structure: {body: {success: true, data: {...}}}
        var scheduleData = data;
        if (data['body'] != null) {
          scheduleData = data['body'];
        }
        if (scheduleData['data'] != null) {
          scheduleData = scheduleData['data'];
        }

        return {'success': true, 'data': scheduleData};
      } else if (response.statusCode == 401) {
        AuthService.logoutAndRedirect();
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania harmonogramu: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Payment Schedule Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Fetch payment history
  Future<Map<String, dynamic>> getPaymentHistory(String parentGuid) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/payments/history/$parentGuid';
      print('🔵 [USER] Fetching payment history from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '🟢 [USER] Payment history response status: ${response.statusCode}',
      );
      print('📄 [USER] Payment history body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var historyData = data;
        if (data['body'] != null) {
          historyData = data['body'];
        }
        if (historyData['data'] != null) {
          historyData = historyData['data'];
        }
        return {'success': true, 'data': historyData};
      } else if (response.statusCode == 401) {
        AuthService.logoutAndRedirect();
        return {
          'success': false,
          'message': 'Sesja wygasła. Zaloguj się ponownie.',
        };
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania historii: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Payment History Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Fetch user relations

  Future<Map<String, dynamic>> getUsersRelations(String parentGuid) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/users-relations/$parentGuid';
      print('🔵 [USER] Fetching relations from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟢 [USER] Relations response status: ${response.statusCode}');
      print('📄 [USER] Relations response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Robust parsing of results
        dynamic relationsRawData;

        if (data is List) {
          relationsRawData = data;
        } else if (data is Map) {
          // Check for common nesting patterns
          var bodyData = data['body'] ?? data;
          relationsRawData =
              bodyData['data'] ?? bodyData['relations'] ?? bodyData['users'];

          // Fallback if success is explicitly false
          if (data['success'] == false ||
              (data['body'] != null && data['body']['success'] == false)) {
            return {
              'success': false,
              'message':
                  data['message'] ??
                  (data['body'] != null ? data['body']['message'] : null) ??
                  'Błąd serwera',
            };
          }
        }

        if (relationsRawData is List) {
          final List<UserProfile> relations = relationsRawData
              .map((json) => UserProfile.fromJson(json))
              .toList();
          return {'success': true, 'relations': relations};
        } else {
          return {
            'success': false,
            'message': 'Nieoczekiwany format danych: ${data.runtimeType}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Błąd pobierania relacji: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Relations Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String guid,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        AuthService.logoutAndRedirect();
        return {'success': false, 'message': 'Brak autoryzacji'};
      }

      final url = '${AuthService.baseUrl}/api/user/profile/$guid';
      print('🔵 [USER] Updating profile at: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('🟢 [USER] Update response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Błąd aktualizacji profilu: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔴 [USER] Update Exception: $e');
      return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
    }
  }
}
