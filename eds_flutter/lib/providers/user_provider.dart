import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/user_consents.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // State
  UserProfile? _profile;
  UserConsents? _consents;
  List<UserProfile>? _relations;

  // Loading Flags
  bool _isLoadingProfile = false;
  bool _isLoadingConsents = false;
  bool _isLoadingRelations = false;

  // Error Messages
  String? _profileError;
  String? _consentsError;
  String? _relationsError;

  // Getters
  UserProfile? get profile => _profile;
  UserConsents? get consents => _consents;
  List<UserProfile>? get relations => _relations;

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingConsents => _isLoadingConsents;
  bool get isLoadingRelations => _isLoadingRelations;

  String? get profileError => _profileError;
  String? get consentsError => _consentsError;
  String? get relationsError => _relationsError;

  /// Fetches the user profile. If `forceRefresh` is false and we already have it, do nothing.
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (_profile != null && !forceRefresh) return;

    _isLoadingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      final result = await _userService.getUserProfile();
      if (result['success'] == true) {
        _profile = result['profile'] as UserProfile;
      } else {
        _profileError = result['message'];
      }
    } catch (e) {
      _profileError = 'Błąd pobierania profilu: $e';
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Fetches the user consents. If `forceRefresh` is false and we already have it, do nothing.
  Future<void> fetchConsents({bool forceRefresh = false}) async {
    if (_consents != null && !forceRefresh) return;

    _isLoadingConsents = true;
    _consentsError = null;
    notifyListeners();

    try {
      final result = await _userService.getUserConsents();
      if (result['success'] == true) {
        _consents = result['consents'] as UserConsents;
      } else {
        _consentsError = result['message'];
      }
    } catch (e) {
      _consentsError = 'Błąd pobierania zgód: $e';
    } finally {
      _isLoadingConsents = false;
      notifyListeners();
    }
  }

  /// Fetches the user relations. If `forceRefresh` is false and we already have it, do nothing.
  Future<void> fetchRelations({bool forceRefresh = false}) async {
    if (_relations != null && !forceRefresh) return;

    _isLoadingRelations = true;
    _relationsError = null;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        _relationsError = 'Brak autoryzacji';
      } else {
        final result = await _userService.getUsersRelations(user.guid);
        if (result['success'] == true) {
          _relations = (result['relations'] as List).cast<UserProfile>();
        } else {
          _relationsError = result['message'];
        }
      }
    } catch (e) {
      _relationsError = 'Błąd pobierania relacji: $e';
    } finally {
      _isLoadingRelations = false;
      notifyListeners();
    }
  }

  /// Clear all data on logout
  void clear() {
    _profile = null;
    _consents = null;
    _relations = null;

    _profileError = null;
    _consentsError = null;
    _relationsError = null;

    _isLoadingProfile = false;
    _isLoadingConsents = false;
    _isLoadingRelations = false;
    notifyListeners();
  }
}
