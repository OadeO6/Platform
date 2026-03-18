import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../router/app_router.dart';

/// The main shell screen that wraps the bottom nav tabs.
/// All 4 main screens (Home, Saved, My Space, Profile) live inside this shell.
/// The centre "Create Item" button is a special nav action — not a tab.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    AppRoutes.home,
    AppRoutes.saved,
    AppRoutes.mySpace,
    AppRoutes.profile,
  ];

  void _onTap(int index) {
    if (index == 2) {
      // Centre button — Create Item
      context.push(AppRoutes.createItem);
      return;
    }

    // Map visual index to tab index (skip centre button slot)
    final tabIndex = index < 2 ? index : index - 1;
    if (tabIndex == _currentIndex) return;
    setState(() => _currentIndex = tabIndex);
    context.go(_tabs[tabIndex]);
  }

  int get _visualIndex => _currentIndex < 2 ? _currentIndex : _currentIndex + 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final selectedColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final unselectedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.divider;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                // Home
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  isActive: _visualIndex == 0,
                  onTap: () => _onTap(0),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),

                // Saved
                _NavItem(
                  icon: Icons.bookmark_outline_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  isActive: _visualIndex == 1,
                  onTap: () => _onTap(1),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),

                // Create Item — centre special button
                _CreateNavItem(
                  onTap: () => _onTap(2),
                  color: selectedColor,
                  borderColor: borderColor,
                ),

                // My Space
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  isActive: _visualIndex == 3,
                  onTap: () => _onTap(3),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),

                // Profile
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  isActive: _visualIndex == 4,
                  onTap: () => _onTap(4),
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isActive ? activeIcon : icon,
              key: ValueKey(isActive),
              color: isActive ? selectedColor : unselectedColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Color borderColor;

  const _CreateNavItem({
    required this.onTap,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(Icons.add_rounded, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}
