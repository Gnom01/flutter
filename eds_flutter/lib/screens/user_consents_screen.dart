import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class UserConsentsScreen extends StatefulWidget {
  const UserConsentsScreen({super.key});

  @override
  State<UserConsentsScreen> createState() => _UserConsentsScreenState();
}

class _UserConsentsScreenState extends State<UserConsentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchConsents());
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final provider = context.watch<UserProvider>();

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
      body: provider.isLoadingConsents && provider.consents == null
          ? const Center(child: CircularProgressIndicator())
          : provider.consentsError != null && provider.consents == null
          ? _buildErrorView(provider)
          : _buildConsentsView(primaryColor, provider),
    );
  }

  Widget _buildErrorView(UserProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.consentsError ?? 'Wystąpił nieoczekiwany błąd',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.fetchConsents(forceRefresh: true),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentsView(Color primaryColor, UserProvider provider) {
    final consents = provider.consents;
    if (consents == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: () => provider.fetchConsents(forceRefresh: true),
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
              value: consents.personalDataProcessingConsent,
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
              value: consents.consentReceiveSmsEmailPhone,
              onChanged: (val) {
                print('Update consentReceiveSmsEmailPhone to $val');
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 12),

            _buildConsentCard(
              title: 'Zgoda marketingowa',
              value: consents.marketingAgreement,
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
