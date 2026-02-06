import 'package:flutter/material.dart';
import '../../widgets/placeholder_screen.dart';

// Dashboard Screen
class ChildDashboardScreen extends StatelessWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Pulpit', icon: Icons.home_outlined);
  }
}

// Schedule Screen
class ChildScheduleScreen extends StatelessWidget {
  const ChildScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Kalendarz zajęć',
      icon: Icons.calendar_today_outlined,
    );
  }
}

// Offers Screen
class ChildOffersScreen extends StatelessWidget {
  const ChildOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Poznaj oferty',
      icon: Icons.star_outline,
    );
  }
}

// Contact Instructor Screen
class ChildContactInstructorScreen extends StatelessWidget {
  const ChildContactInstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Kontakt z instruktorem',
      icon: Icons.chat_outlined,
    );
  }
}

// Help Screen
class ChildHelpScreen extends StatelessWidget {
  const ChildHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: 'Pomoc', icon: Icons.help_outline);
  }
}
