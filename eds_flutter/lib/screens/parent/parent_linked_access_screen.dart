import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentLinkedAccessScreen extends StatefulWidget {
  const ParentLinkedAccessScreen({super.key});

  @override
  State<ParentLinkedAccessScreen> createState() =>
      _ParentLinkedAccessScreenState();
}

class _ParentLinkedAccessScreenState extends State<ParentLinkedAccessScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchRelations());
  }

  void _showEditCredentialsDialog(UserProfile profile, UserProvider provider) {
    final loginController = TextEditingController(text: profile.email);
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    bool isSaving = false;
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dane logowania',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.fullName,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: loginController,
                      decoration: InputDecoration(
                        labelText: 'Login (Email)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Podaj login' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Nowe hasło',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Podaj hasło' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE20613),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => isSaving = true);

                              final result = await _userService
                                  .updateUserCredentials(
                                    profile.guid,
                                    loginController.text.trim(),
                                    passwordController.text,
                                  );

                              if (!context.mounted) return;
                              setModalState(() => isSaving = false);
                              if (result['success'] == true) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Zapisano dane logowania dla ${profile.firstName}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                provider.fetchRelations(
                                  forceRefresh: true,
                                ); // Refresh
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ?? 'Błąd zapisu danych',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Zapisz',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dostępy',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: provider.isLoadingRelations && provider.relations == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE20613)),
            )
          : provider.relationsError != null && provider.relations == null
          ? _buildErrorView(provider)
          : _buildRelationsList(provider),
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
              provider.relationsError ?? 'Wystąpił nieoczekiwany błąd',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE20613),
              ),
              onPressed: () => provider.fetchRelations(forceRefresh: true),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationsList(UserProvider provider) {
    final relations = provider.relations;
    if (relations == null || relations.isEmpty) {
      return Center(
        child: Text(
          'Brak powiązanych osób',
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchRelations(forceRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: relations.length,
        itemBuilder: (context, index) {
          final profile = relations[index];
          return _buildRelationCard(profile, provider);
        },
      ),
    );
  }

  Widget _buildRelationCard(UserProfile profile, UserProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE20613).withOpacity(0.1),
              child: Text(
                profile.firstName.isNotEmpty ? profile.firstName[0] : 'U',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFFE20613),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName.trim().isEmpty
                        ? 'Brak imienia i nazwiska'
                        : profile.fullName,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.email.isNotEmpty
                              ? profile.email
                              : 'Brak loginu',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showEditCredentialsDialog(profile, provider),
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Color(0xFFE20613),
              ),
              label: Text(
                'Edytuj',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE20613),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                backgroundColor: const Color(0xFFE20613).withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
