import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../services/providers.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  static List<_NavItem> _items(bool isFrench) => [
    _NavItem(icon: Icons.home, filledIcon: Icons.home, label: isFrench ? 'Accueil' : 'Home', route: AppRoutes.mainDashboard),
    _NavItem(icon: Icons.sensors, filledIcon: Icons.sensors, label: isFrench ? 'Direct' : 'Live', route: AppRoutes.liveMonitoring),
    _NavItem(icon: Icons.notifications_active_outlined, filledIcon: Icons.notifications_active, label: isFrench ? 'Alertes' : 'Alerts', route: AppRoutes.alerts),
    _NavItem(icon: Icons.insights_outlined, filledIcon: Icons.insights, label: isFrench ? 'Historique' : 'History', route: AppRoutes.history),
    _NavItem(icon: Icons.person_outline, filledIcon: Icons.person, label: isFrench ? 'Profil' : 'Profile', route: AppRoutes.userProfile),
  ];

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    final items = _items(isFrench);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceColor(context) : AppTheme.surface;
    final borderColor = isDark ? AppTheme.borderStrong(context) : AppTheme.outlineVariant.withValues(alpha: 0.2);
    final unselectedColor = isDark ? AppTheme.subtext(context) : AppTheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return _buildNavItem(context, item, isSelected, index, unselectedColor);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, bool isSelected, int index, Color unselectedColor) {
    return InkWell(
      onTap: () {
        if (currentIndex != index) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            item.route,
            (route) => false,
          );
        }
      },
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.filledIcon : item.icon,
              color: isSelected ? AppTheme.primary : unselectedColor,
              size: 23,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                height: 16 / 11,
                letterSpacing: 0.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.route,
  });
}
