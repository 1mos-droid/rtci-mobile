import 'package:flutter/material.dart';
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
  // Build each feature on first visit, then preserve its state.
  final Map<int, Widget> _pages = {0: const DashboardScreen()};
  void _select(int index) => setState(() {
    _pages.putIfAbsent(
      index,
      () => switch (index) {
        1 => const LiveBibleScreen(),
        2 => const GivingScreen(),
        _ => const MenuScreen(),
      },
    );
    _currentIndex = index;
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 840;
      final content = IndexedStack(
        index: _currentIndex,
        children: List.generate(
          4,
          (i) => TickerMode(
            enabled: i == _currentIndex,
            child: ExcludeFocus(
              excluding: i != _currentIndex,
              child: _pages[i] ?? const SizedBox.shrink(),
            ),
          ),
        ),
      );
      return Scaffold(
        body: wide
            ? Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      selectedIndex: _currentIndex,
                      onDestinationSelected: _select,
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Image.asset(
                          'assets/church_logo.png',
                          width: 42,
                          height: 42,
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.auto_stories_outlined),
                          label: Text('Bible'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite_border_rounded),
                          label: Text('Give'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.grid_view_rounded),
                          label: Text('Explore'),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              )
            : content,
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _select,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_stories_outlined),
                    label: 'Bible',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    label: 'Give',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    label: 'Explore',
                  ),
                ],
              ),
      );
    },
  );
}
