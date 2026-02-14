import 'package:flutter/material.dart';
import '../../widgets/placeholder_screen.dart';

// Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Twoje dane',
      icon: Icons.person_outline,
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Ustawienia',
      icon: Icons.settings_outlined,
    );
  }
}

// Consents Screen
class ConsentsScreen extends StatelessWidget {
  const ConsentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Zgody',
      icon: Icons.check_circle_outline,
    );
  }
}

// Feedback Screen
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Zostaw opinie',
      icon: Icons.thumb_up_alt_outlined,
    );
  }
}
