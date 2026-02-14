import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserProfile? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.getUserProfile();
      if (result['success']) {
        setState(() {
          _profile = result['profile'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Błąd: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Twój Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildProfileView(primaryColor),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Wystąpił nieoczekiwany błąd',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProfile,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(Color primaryColor) {
    if (_profile == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with Avatar
            _buildProfileHeader(primaryColor),
            const SizedBox(height: 24),

            // Personal Info Card
            _buildInfoCard(
              title: 'Dane osobowe',
              icon: Icons.person_outline,
              items: [
                _buildInfoRow('Imię i nazwisko', _profile!.fullName),
                _buildInfoRow('PESEL', _profile!.pesel),
                _buildInfoRow('Data urodzenia', _profile!.dateOfBirth),
                _buildInfoRow(
                  'Nr karty',
                  _profile!.memberCardNumber.isEmpty
                      ? 'Brak'
                      : _profile!.memberCardNumber,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Info Card
            _buildInfoCard(
              title: 'Dane kontaktowe',
              icon: Icons.contact_mail_outlined,
              items: [
                _buildInfoRow('Email', _profile!.email),
                _buildInfoRow('Telefon', _profile!.phone),
              ],
            ),
            const SizedBox(height: 16),

            // Address Card
            _buildInfoCard(
              title: 'Adres zamieszkania',
              icon: Icons.home_outlined,
              items: [
                _buildInfoRow(
                  'Ulica',
                  '${_profile!.street} ${_profile!.building}${_profile!.flat.isNotEmpty ? '/${_profile!.flat}' : ''}',
                ),
                _buildInfoRow(
                  'Miasto',
                  '${_profile!.postalCode} ${_profile!.city}',
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
              _profile!.firstName.isNotEmpty ? _profile!.firstName[0] : 'U',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _profile!.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
