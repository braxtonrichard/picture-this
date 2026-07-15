import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/glass_nav_bar.dart';

const List<String> _tabPaths = <String>['/', '/experiences', '/profile'];

const List<GlassNavDestination> _destinations = <GlassNavDestination>[
  GlassNavDestination(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore,
    label: 'Discover',
  ),
  GlassNavDestination(
    icon: Icons.auto_awesome_outlined,
    activeIcon: Icons.auto_awesome,
    label: 'Experiences',
  ),
  GlassNavDestination(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
  ),
];

/// The bottom-nav shell wrapping Discover / Experiences / Profile — the
/// three primary destinations of the core loop.
class RootShell extends StatelessWidget {
  const RootShell({required this.child, super.key});

  final Widget child;

  int _indexForLocation(String location) {
    final int index = _tabPaths.indexOf(location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: GlassNavBar(
        destinations: _destinations,
        currentIndex: _indexForLocation(location),
        onTap: (int index) => context.go(_tabPaths[index]),
      ),
    );
  }
}
