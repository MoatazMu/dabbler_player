import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/games/games_screen.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/social/social_screen.dart';
import '../themes/app_theme.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  
  const BottomNavigation({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const GamesScreen(),
    const ActivitiesScreen(),
    const SocialScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: context.colors.primary.withOpacity(0.2),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, LucideIcons.home, 'Home'),
                  _buildNavItem(1, LucideIcons.galleryVertical, 'Explore'),
                  _buildNavItem(2, LucideIcons.gamepad2, 'Games'),
                  _buildNavItem(3, LucideIcons.activity, 'Activity'),
                  _buildNavItem(4, LucideIcons.users, 'Social'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected ? BoxDecoration(
            color: context.colors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? context.colors.primary
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                      ? context.colors.primary
                      : context.colors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
