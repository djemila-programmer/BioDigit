import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/biodigester_model.dart';
import '../routes.dart';
import '../services/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocaleProvider>(
      builder: (context, auth, localeProvider, _) {
        final user = auth.user;
        final isFrench = localeProvider.isFrench;
        final isAdmin = user?.role == 'admin';

        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            leading: showBackButton
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.onSurface),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            title: Text(isFrench ? 'Profil' : 'Profile', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
            elevation: 0,
          ),
          bottomNavigationBar: showBackButton ? null : const BottomNavBar(currentIndex: 4),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryContainer],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(Icons.person, color: Colors.white, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName : (isFrench ? 'Utilisateur' : 'User'),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role ?? 'user',
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.farmName ?? (isFrench ? 'Ferme non renseignée' : 'No farm specified'),
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(isFrench ? 'Contact' : 'Contact'),
                      const SizedBox(height: 12),
                      _infoCard([
                        _infoRow(Icons.email, 'Email', user?.email ?? ''),
                        _infoRow(Icons.phone, isFrench ? 'Téléphone' : 'Phone', user?.phone.isNotEmpty == true ? user!.phone : (isFrench ? 'Non renseigné' : 'Not specified')),
                        if (isAdmin) _infoRow(Icons.badge, 'ID', user?.id ?? ''),
                      ]),
                      const SizedBox(height: 24),
                      _sectionTitle(isFrench ? 'Aperçu de la ferme' : 'Farm Overview'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _quickStat('124', 'Cattle', Icons.pets, AppTheme.primary),
                          _quickStat('86', 'Swine', Icons.grid_view, AppTheme.secondary),
                          _quickStat('2', isFrench ? 'Digesteurs' : 'Digesters', Icons.storage, AppTheme.tertiary),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle(isFrench ? 'Biodigesteur' : 'Biodigester'),
                      const SizedBox(height: 12),
                      _biodigesterStats(),
                      const SizedBox(height: 24),
                      _sectionTitle(isFrench ? 'Actions' : 'Actions'),
                      const SizedBox(height: 12),
                      _actionRow(Icons.analytics, isFrench ? 'Voir les rapports' : 'View reports', AppRoutes.reports, AppTheme.primary),
                      _actionRow(Icons.settings, isFrench ? 'Paramètres' : 'Settings', AppRoutes.settings, cs.onSurfaceVariant),
                      _actionRow(Icons.help_outline, isFrench ? 'Aide & support' : 'Help & support', '', AppTheme.tertiary),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await auth.signOut();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                          },
                          icon: const Icon(Icons.logout, color: AppTheme.error),
                          label: Text(isFrench ? 'Déconnexion' : 'Sign out', style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.error, width: 1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
      );
    });
  }

  Widget _infoCard(List<Widget> children) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(children: children),
      );
    });
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _quickStat(String value, String label, IconData icon, Color color) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
              Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    });
  }

  Widget _biodigesterStats() {
    final bio = BiodigesterModel.mockBiodigester;
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _bioStat(Icons.storage, 'Capacity', '${bio.capacity} m³', AppTheme.primary),
              const SizedBox(width: 12),
              _bioStat(Icons.trending_up, 'Efficiency', '${bio.efficiency}%', AppTheme.tertiary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _bioStat(Icons.bolt, 'Energy', '${bio.energyGenerated} kWh', AppTheme.secondary),
              const SizedBox(width: 12),
              _bioStat(Icons.eco, 'CO₂ Saved', '${bio.co2Reduction.toInt()} kg', const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _bioStat(Icons.calendar_today, 'Today', '${bio.todayProduction} m³', AppTheme.primary),
              const SizedBox(width: 12),
              _bioStat(Icons.calendar_view_week, 'Weekly', '${bio.weeklyProduction} m³', AppTheme.tertiary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _bioStat(Icons.calendar_month, 'Monthly', '${bio.monthlyProduction} m³', AppTheme.secondary),
              const SizedBox(width: 12),
              _bioStat(Icons.calendar_view_month, 'Yearly', '${bio.yearlyProduction} m³', AppTheme.primary),
            ],
          ),
        ],
      ),
    );});
  }

  Widget _bioStat(IconData icon, String label, String value, Color color) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 9, color: cs.outline)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
            ],
          ),
        ),
      );
    });
  }

  Widget _actionRow(IconData icon, String label, String route, Color color) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return InkWell(
        onTap: () {
          if (route.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label bientôt disponible.')),
            );
            return;
          }
          Navigator.pushNamed(context, route);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface))),
              Icon(Icons.chevron_right, size: 20, color: cs.outline),
            ],
          ),
        ),
      );
      },
    );
  }
}
