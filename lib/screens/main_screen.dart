import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'game_screen.dart';
import 'search_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    ItemConfig item(IconData icon, String title) => ItemConfig(
      icon: Icon(icon),
      title: title,
      activeForegroundColor: scheme.primary,
      inactiveForegroundColor: scheme.onSurfaceVariant,
    );

    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const GameScreen(),
          item: item(Icons.sports_esports, 'Games'),
        ),
        PersistentTabConfig(
          screen: const SearchScreen(),
          item: item(Icons.search, 'Search'),
        ),
        PersistentTabConfig(
          screen: const SettingScreen(),
          item: item(Icons.settings, 'Settings'),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style9BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(color: scheme.surfaceContainer),
      ),
    );
  }
}
