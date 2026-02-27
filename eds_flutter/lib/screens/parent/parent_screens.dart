import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_profile.dart';
import '../user_edit_screen.dart';
import '../../widgets/placeholder_screen.dart';
import '../payment_schedule_screen.dart';

// Related Persons Screen
class ParentRelatedPersonsScreen extends StatefulWidget {
  const ParentRelatedPersonsScreen({super.key});

  @override
  State<ParentRelatedPersonsScreen> createState() =>
      _ParentRelatedPersonsScreenState();
}

class _ParentRelatedPersonsScreenState
    extends State<ParentRelatedPersonsScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  List<UserProfile>? _relations;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRelations();
  }

  Future<void> _fetchRelations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        setState(() {
          _errorMessage = 'Nie znaleziono danych użytkownika';
          _isLoading = false;
        });
        return;
      }

      final result = await _userService.getUsersRelations(user.guid);
      if (result['success']) {
        setState(() {
          _relations = result['relations'];
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Osoby powiązane',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRelations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildRelationsList(),
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
              onPressed: _fetchRelations,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationsList() {
    if (_relations == null || _relations!.isEmpty) {
      return const Center(child: Text('Brak powiązanych osób'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _relations!.length,
      itemBuilder: (context, index) {
        final profile = _relations![index];
        return _buildRelationCard(profile);
      },
    );
  }

  Widget _buildRelationCard(UserProfile profile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              profile.firstName.isNotEmpty ? profile.firstName[0] : 'U',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: profile.fullName.trim().isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                if (profile.email.isNotEmpty)
                  Text(
                    profile.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Color(0xFFE20613)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserEditScreen(profile: profile),
                ),
              );
              if (result == true) {
                _fetchRelations();
              }
            },
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Pulpit', icon: Icons.home_outlined);
  }
}

// Payments Screen
class ParentPaymentsScreen extends StatelessWidget {
  const ParentPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentScheduleScreen();
  }
}

// Offers Screen
class ParentOffersScreen extends StatelessWidget {
  const ParentOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Poznaj ofertę',
      icon: Icons.star_outline,
    );
  }
}

// Schedule Screen
class ParentScheduleScreen extends StatelessWidget {
  const ParentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Kalendarz zajęć',
      icon: Icons.calendar_today_outlined,
    );
  }
}

// Contact Instructor Screen
class ParentContactInstructorScreen extends StatelessWidget {
  const ParentContactInstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Kontakt z instruktorem',
      icon: Icons.chat_outlined,
    );
  }
}

// Tickets Screen
class ParentTicketsScreen extends StatelessWidget {
  const ParentTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Bilety',
      icon: Icons.confirmation_number_outlined,
    );
  }
}

// Help Screen
class ParentHelpScreen extends StatelessWidget {
  const ParentHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Pomoc / Kontakt',
      icon: Icons.help_outline,
    );
  }
}
