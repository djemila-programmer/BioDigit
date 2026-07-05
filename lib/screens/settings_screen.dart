import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes.dart';
import '../services/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, LocaleProvider>(
      builder: (context, auth, theme, localeProvider, _) {
        final user = auth.user;
        final isFrench = localeProvider.isFrench;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppHeader(title: isFrench ? 'Paramètres' : 'Settings', showBackButton: true),
          bottomNavigationBar: const BottomNavBar(currentIndex: 4),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: cs.primaryContainer.withValues(alpha: 0.2),
                          child: Icon(Icons.person, color: cs.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? (isFrench ? 'Utilisateur' : 'User'),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                              ),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: cs.outline),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(isFrench ? 'Compte' : 'Account', color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                _settingsTile(context, Icons.security, isFrench ? 'Sécurité' : 'Security', isFrench ? 'Mot de passe, session et protection' : 'Password, session and protection', () => Navigator.pushNamed(context, AppRoutes.changePassword)),
                _settingsTile(context, Icons.wifi, isFrench ? 'Connexion ESP32' : 'ESP32 Connection', isFrench ? 'Connecté · 192.168.1.100' : 'Connected · 192.168.1.100', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isFrench ? 'Les détails de connexion ESP32 sont en lecture seule.' : 'ESP32 connection details are read-only for now.')),
                  );
                }),
                _settingsTile(context, Icons.notifications_outlined, isFrench ? 'Notifications' : 'Notifications', isFrench ? 'Alertes et notifications push' : 'Alerts and push settings', () => Navigator.pushNamed(context, AppRoutes.notifications)),
                const SizedBox(height: 24),
                _sectionTitle(isFrench ? 'Préférences' : 'Preferences', color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                _languageTile(context, localeProvider, isFrench),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.dark_mode, size: 20, color: cs.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(isFrench ? 'Mode sombre' : 'Dark Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface)),
                      ),
                      Switch(
                        value: theme.isDark,
                        onChanged: (value) => theme.toggleTheme(value),
                        activeColor: cs.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(isFrench ? 'Support' : 'Support', color: cs.onSurfaceVariant),
                const SizedBox(height: 12),
                _settingsTile(context, Icons.help_outline, isFrench ? "Centre d'aide" : 'Help Center', isFrench ? 'FAQ et guides' : 'FAQs & guides', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isFrench ? "Le centre d'aide sera disponible dans la prochaine version." : 'Help center will be available in the next release.')),
                  );
                }),
                _settingsTile(context, Icons.info_outline, isFrench ? 'À propos' : 'About', '${isFrench ? 'Version' : 'Version'} 2.1.0', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('BioDigit app v2.1.0')), 
                  );
                }),
                _settingsTile(context, Icons.privacy_tip_outlined, isFrench ? 'Politique de confidentialité' : 'Privacy Policy', isFrench ? 'Données et autorisations' : 'Data & permissions', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isFrench ? 'La page de politique de confidentialité arrive bientôt.' : 'Privacy policy page is coming soon.')),
                  );
                }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    },
                    icon: Icon(Icons.logout, color: cs.error),
                    label: Text(isFrench ? 'Déconnexion' : 'Sign out', style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: cs.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, {Color? color}) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5),
    );
  }

  Widget _settingsTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: cs.outline),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(BuildContext context, LocaleProvider localeProvider, bool isFrench) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.language, size: 20, color: cs.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(isFrench ? 'Langue' : 'Language', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurface)),
          ),
          DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            underline: const SizedBox(),
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            items: [
              DropdownMenuItem(value: 'fr', child: Text(isFrench ? 'Français' : 'French')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                localeProvider.setLocale(Locale(value));
              }
            },
          ),
        ],
      ),
    );
  }
}
