import 'package:flutter/material.dart';
import '../models/user_consents.dart';
import '../services/user_service.dart';

class UserConsentsScreen extends StatefulWidget {
  const UserConsentsScreen({super.key});

  @override
  State<UserConsentsScreen> createState() => _UserConsentsScreenState();
}

class _UserConsentsScreenState extends State<UserConsentsScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserConsents? _consents;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConsents();
  }

  Future<void> _fetchConsents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _userService.getUserConsents();
      if (result['success']) {
        setState(() {
          _consents = result['consents'];
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
          'Zgody',
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
          : _buildConsentsView(primaryColor),
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
              onPressed: _fetchConsents,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentsView(Color primaryColor) {
    if (_consents == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _fetchConsents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Zarządzaj swoimi zgodami i preferencjami komunikacyjnymi.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            _buildConsentCard(
              title: 'Zgoda na przetwarzanie danych osobowych *',
              value: _consents!.personalDataProcessingConsent,
              onChanged: (val) {
                // In a real app, we would call an API to update this
                print('Update personalDataProcessingConsent to $val');
              },
              primaryColor: primaryColor,
              isMandatory: true,
            ),
            const SizedBox(height: 12),

            _buildConsentCard(
              title: 'Zgoda na SMS/email/telefon',
              value: _consents!.consentReceiveSmsEmailPhone,
              onChanged: (val) {
                print('Update consentReceiveSmsEmailPhone to $val');
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 12),

            _buildConsentCard(
              title: 'Zgoda marketingowa',
              value: _consents!.marketingAgreement,
              onChanged: (val) {
                print('Update marketingAgreement to $val');
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '* Pola oznaczone gwiazdką są wymagane dla poprawnego funkcjonowania serwisu.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color primaryColor,
    bool isMandatory = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: isMandatory
            ? const Text(
                'Wymagana do korzystania z panelu',
                style: TextStyle(fontSize: 12),
              )
            : null,
        value: value,
        onChanged: isMandatory
            ? null
            : (bool newValue) {
                setState(() {
                  // For now just local state update if we had a way to mutate UserConsents
                  // or we'd emit a request to API here.
                });
                onChanged(newValue);
              },
        activeColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
