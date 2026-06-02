import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rtc_mobile/theme/app_theme.dart';
import 'package:rtc_mobile/ui/features/dashboard/dashboard_screen.dart';
import 'package:rtc_mobile/ui/features/spiritual/live_bible_screen.dart';
import 'package:rtc_mobile/ui/features/finance/giving_screen.dart';
import 'package:rtc_mobile/ui/features/settings/menu_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const LiveBibleScreen(),
    const GivingScreen(),
    const MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsidianTheme.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ObsidianTheme.surfaceDark.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(color: ObsidianTheme.borderHairline, width: 0.5),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: ObsidianTheme.primaryCrimson,
              unselectedItemColor: ObsidianTheme.textMuted,
              selectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              iconSize: 28,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Bible',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.volunteer_activism_outlined),
                  activeIcon: Icon(Icons.volunteer_activism),
                  label: 'Give',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_rounded),
                  activeIcon: Icon(Icons.menu_open_rounded),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

