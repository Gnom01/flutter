import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/common/common_screens.dart';
import '../screens/child/child_screens.dart'; // For ChildHelpScreen
import '../screens/parent/parent_screens.dart'; // For ParentHelpScreen
import '../screens/instructor/instructor_screens.dart'; // For InstructorHelpScreen
import '../models/user.dart';
import '../screens/user_profile_screen.dart';
import '../screens/user_consents_screen.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final User user;
  final VoidCallback onDashboardTap;

  const CustomNavigationDrawer({
    super.key,
    required this.user,
    required this.onDashboardTap,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Wyloguj',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Czy na pewno chcesz się wylogować?',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Anuluj', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Wyloguj',
              style: GoogleFonts.lato(color: const Color(0xFFE20613)),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (context.mounted) {
        await authService.logout();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Rectangular drawer as per request
      ),
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            color: Colors.white, // Setting white background for header area
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left arrow
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1F2937),
                      ),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Zamknij',
                    ),
                    // Right close icon (X)
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF111827)),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Zamknij',
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Pulpit',
                  onTap: () {
                    Navigator.pop(context);
                    onDashboardTap();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Twoje dane',
                  onTap: () => _navigateTo(context, const UserProfileScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Ustawienia',
                  onTap: () => _navigateTo(context, const SettingsScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.check_circle_outline,
                  title: 'Zgody',
                  onTap: () => _navigateTo(context, const UserConsentsScreen()),
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Pomoc i kontakt',
                  onTap: () {
                    // Navigate to appropriate help screen based on role
                    Widget helpScreen;
                    if (user.isInstructor) {
                      helpScreen = const InstructorHelpScreen();
                    } else if (user.isParent) {
                      helpScreen = const ParentHelpScreen();
                    } else {
                      helpScreen = const ChildHelpScreen();
                    }
                    _navigateTo(context, helpScreen);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Zostaw opinie',
                  onTap: () => _navigateTo(context, const FeedbackScreen()),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Wyloguj',
                  onTap: () => _handleLogout(context),
                  textColor: const Color(0xFFE20613),
                  iconColor: const Color(0xFFE20613),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF1F2937)),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xFF1F2937),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      horizontalTitleGap: 8,
    );
  }
}
