import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import '../user_edit_screen.dart';
import '../../widgets/placeholder_screen.dart';
import '../payment_schedule_screen.dart';

export 'parent_linked_access_screen.dart';

// Related Persons Screen
class ParentRelatedPersonsScreen extends StatefulWidget {
  const ParentRelatedPersonsScreen({super.key});

  @override
  State<ParentRelatedPersonsScreen> createState() =>
      _ParentRelatedPersonsScreenState();
}

class _ParentRelatedPersonsScreenState
    extends State<ParentRelatedPersonsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().fetchRelations());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

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
            onPressed: () => provider.fetchRelations(forceRefresh: true),
          ),
        ],
      ),
      body: provider.isLoadingRelations && provider.relations == null
          ? const Center(child: CircularProgressIndicator())
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
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
      return const Center(child: Text('Brak powiązanych osób'));
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
                provider.fetchRelations(forceRefresh: true);
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
