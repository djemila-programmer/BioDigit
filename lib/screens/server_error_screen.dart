import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../routes.dart';

class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.containerPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 64,
                        color: AppTheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '500 — Erreur serveur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Une erreur est survenue. Réessayez dans quelques instants ou revenez à l’accueil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.landing,
                      (route) => false,
                    ),
                    icon: const Icon(
                      Icons.refresh_outlined,
                      color: Colors.white,
                    ),
                    label: const Text('Retour accueil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
