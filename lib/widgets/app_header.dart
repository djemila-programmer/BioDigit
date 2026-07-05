import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    this.title = 'BioDigit',
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceColor(context) : AppTheme.surface;
    final borderColor = isDark ? AppTheme.borderStrong(context) : AppTheme.outlineVariant.withValues(alpha: 0.18);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.containerPadding,
            vertical: AppTheme.baseSpacing,
          ),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.12),
                child: const Icon(Icons.eco, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title ?? 'BioDigit',
                style: const TextStyle(
                  fontSize: 20,
                  height: 26 / 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.onSurfaceVariant),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
