import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../widgets/navigation_drawer.dart';

// Child screens
import 'child/child_screens.dart';

// Parent screens
import 'parent/parent_screens.dart';

// Instructor screens
import 'instructor/instructor_screens.dart';

class MainNavigationScreen extends StatefulWidget {
  final User user;

  const MainNavigationScreen({super.key, required this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Get menu items based on user's primary role
  List<NavigationItem> get _menuItems {
    final primaryRole = widget.user.primaryRole;

    if (primaryRole == 1) {
      // Child menu
      return [
        NavigationItem(
          label: 'Pulpit',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          screen: const ChildDashboardScreen(),
        ),
        NavigationItem(
          label: 'Kalendarz',
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          screen: const ChildScheduleScreen(),
        ),
        NavigationItem(
          label: 'Oferty',
          icon: Icons.star_outline,
          selectedIcon: Icons.star,
          screen: const ChildOffersScreen(),
        ),
        NavigationItem(
          label: 'Kontakt',
          icon: Icons.chat_outlined,
          selectedIcon: Icons.chat,
          screen: const ChildContactInstructorScreen(),
        ),
      ];
    } else if (primaryRole == 2) {
      // Parent menu
      return [
        NavigationItem(
          label: 'Pulpit',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          screen: const ParentDashboardScreen(),
        ),
        NavigationItem(
          label: 'Płatności',
          icon: Icons.credit_card_outlined,
          selectedIcon: Icons.credit_card,
          screen: const ParentPaymentsScreen(),
        ),
        NavigationItem(
          label: 'Osoby',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          screen: const ParentRelatedPersonsScreen(),
        ),
        NavigationItem(
          label: 'Oferty',
          icon: Icons.star_outline,
          selectedIcon: Icons.star,
          screen: const ParentOffersScreen(),
        ),
        NavigationItem(
          label: 'Więcej',
          icon: Icons.more_horiz,
          selectedIcon: Icons.more_horiz,
          screen: _buildMoreScreen(),
        ),
      ];
    } else if (primaryRole == 3) {
      // Instructor menu
      return [
        NavigationItem(
          label: 'Pulpit',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          screen: const InstructorDashboardScreen(),
        ),
        NavigationItem(
          label: 'Harmonogram',
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          screen: const InstructorScheduleScreen(),
        ),
        NavigationItem(
          label: 'Zmiany',
          icon: Icons.edit_calendar_outlined,
          selectedIcon: Icons.edit_calendar,
          screen: const InstructorScheduleChangesScreen(),
        ),
        NavigationItem(
          label: 'Zgłoszenia',
          icon: Icons.report_outlined,
          selectedIcon: Icons.report,
          screen: const InstructorReportsScreen(),
        ),
      ];
    }

    // Default fallback
    return [];
  }

  // Build "More" screen for Parent role (since they have 8 items)
  Widget _buildMoreScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Więcej',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMoreMenuItem(
            icon: Icons.calendar_today_outlined,
            title: 'Kalendarz zajęć',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ParentScheduleScreen(),
              ),
            ),
          ),
          _buildMoreMenuItem(
            icon: Icons.chat_outlined,
            title: 'Kontakt z instruktorem',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ParentContactInstructorScreen(),
              ),
            ),
          ),
          _buildMoreMenuItem(
            icon: Icons.confirmation_number_outlined,
            title: 'Bilety',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ParentTicketsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE20613)),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Handles navigation when "Pulpit" is clicked in Drawer
  void _onDrawerDashboardTap() {
    setState(() {
      _currentIndex = 0; // Switch to first tab (Dashboard)
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _menuItems;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomNavigationDrawer(
        user: widget.user,
        onDashboardTap: _onDrawerDashboardTap,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1F2937)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Egurrola D|S',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w400,
            color: const Color(0xFFCC0033),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Notifications icon
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFFE20613),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE20613),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '3',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Powiadomienia - w przygotowaniu',
                    style: GoogleFonts.lato(),
                  ),
                  backgroundColor: const Color(0xFFE20613),
                ),
              );
            },
          ),
        ],
      ),
      body: menuItems.isNotEmpty
          ? menuItems[_currentIndex].screen
          : const Center(child: Text('Brak dostępnych opcji menu')),
      bottomNavigationBar: menuItems.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFFE20613),
                unselectedItemColor: Colors.grey.shade600,
                selectedLabelStyle: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                elevation: 0,
                items: menuItems
                    .map(
                      (item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        activeIcon: Icon(item.selectedIcon),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            )
          : null,
    );
  }
}

class NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
