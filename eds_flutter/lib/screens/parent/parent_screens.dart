import 'package:flutter/material.dart';
import '../../widgets/placeholder_screen.dart';

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
    return const PlaceholderScreen(
      title: 'Płatności / Historia',
      icon: Icons.credit_card_outlined,
    );
  }
}

// Related Persons Screen
class ParentRelatedPersonsScreen extends StatelessWidget {
  const ParentRelatedPersonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Osoby powiązane',
      icon: Icons.people_outline,
    );
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
