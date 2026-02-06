import 'package:flutter/material.dart';
import '../../widgets/placeholder_screen.dart';

// Dashboard Screen
class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Pulpit', icon: Icons.home_outlined);
  }
}

// Schedule Screen
class InstructorScheduleScreen extends StatelessWidget {
  const InstructorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Harmonogram zajęć',
      icon: Icons.calendar_today_outlined,
    );
  }
}

// Schedule Changes Screen
class InstructorScheduleChangesScreen extends StatelessWidget {
  const InstructorScheduleChangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Zmiany w harmonogramie',
      icon: Icons.edit_calendar_outlined,
    );
  }
}

// Reports Screen
class InstructorReportsScreen extends StatelessWidget {
  const InstructorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Zgłoszenia',
      icon: Icons.report_outlined,
    );
  }
}

// Help Screen
class InstructorHelpScreen extends StatelessWidget {
  const InstructorHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Pomoc / Kontakt',
      icon: Icons.help_outline,
    );
  }
}
