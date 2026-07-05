import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withValues(alpha: 0.10),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.eco, color: AppTheme.onPrimary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'BioDigit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text('Connexion'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text('Créer un compte'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 760;
                      final content = isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: _HeroSection(onPrimaryAction: () => Navigator.pushNamed(context, AppRoutes.login))),
                                const SizedBox(width: 24),
                                const Expanded(child: _HighlightsPanel()),
                              ],
                            )
                          : Column(
                              children: [
                                _HeroSection(onPrimaryAction: () => Navigator.pushNamed(context, AppRoutes.login)),
                                const SizedBox(height: 20),
                                const _HighlightsPanel(),
                              ],
                            );

                      return Column(
                        children: [
                          content,
                          const SizedBox(height: 28),
                          const _FeatureGrid(),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pourquoi BioDigit ?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Supervisez votre installation, sécurisez vos alertes et suivez vos indicateurs dans une interface pensée pour l’usage terrain et l’exploitation quotidienne.',
                                  style: TextStyle(fontSize: 14, height: 1.6, color: cs.onSurfaceVariant.withValues(alpha: 0.95)),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: const [
                                    _Pill(label: 'Monitoring IoT'),
                                    _Pill(label: 'Alertes en temps réel'),
                                    _Pill(label: 'Tableaux de bord KPI'),
                                    _Pill(label: 'Gestion des fermes'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _CtaBand(
                            onLogin: () => Navigator.pushNamed(context, AppRoutes.login),
                            onRegister: () => Navigator.pushNamed(context, AppRoutes.register),
                          ),
                          const SizedBox(height: 28),
                          const _Footer(),
                        ],
                      );
                    },
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

class _HeroSection extends StatelessWidget {
  final VoidCallback onPrimaryAction;

  const _HeroSection({required this.onPrimaryAction});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.eco, color: AppTheme.onPrimary, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BioDigit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Biodigester Monitoring System',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Supervisez vos biodigesteurs, vos alertes et vos performances agricoles depuis une seule interface claire.',
            style: TextStyle(fontSize: 18, height: 1.5, color: cs.onSurface, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 14),
          Text(
            'Une solution pensée pour le terrain, les équipes locales et la croissance durable des exploitations au Burkina Faso.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: cs.onSurfaceVariant.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _Pill(label: 'Suivi temps réel'),
              _Pill(label: 'Supabase Auth'),
              _Pill(label: 'Alertes intelligentes'),
              _Pill(label: 'Responsive mobile-first'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPrimaryAction,
              child: const Text('Accéder au tableau de bord'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsPanel extends StatelessWidget {
  const _HighlightsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.92),
            AppTheme.primaryContainer.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Points forts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          _HighlightItem(icon: Icons.sensors, title: 'Capteurs connectés', description: 'Température, pression, méthane et niveau de substrat.'),
          _HighlightItem(icon: Icons.notifications_active, title: 'Alertes critiques', description: 'Notifications dès qu’un seuil devient dangereux.'),
          _HighlightItem(icon: Icons.insights, title: 'KPI clairs', description: 'Suivi de production et état global en un coup d’œil.'),
          _HighlightItem(icon: Icons.security, title: 'Sécurité Supabase', description: 'Auth, redirections et protection des routes.'),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final features = <_FeatureCardData>[
      _FeatureCardData(Icons.eco, 'Énergie verte', 'Valorisez les déchets organiques en biogaz utile.'),
      _FeatureCardData(Icons.track_changes, 'Monitoring', 'Visualisez les mesures clés et les tendances.'),
      _FeatureCardData(Icons.auto_graph, 'Analytics', 'Suivez les performances et les anomalies.'),
      _FeatureCardData(Icons.groups, 'Équipe', 'Travaillez avec des rôles et des accès sécurisés.'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columns == 1 ? 3.4 : 1.15,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(feature.icon, color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.description,
                          style: TextStyle(fontSize: 13, height: 1.45, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.95)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CtaBand extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _CtaBand({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prêt à démarrer ?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous si vous avez déjà un compte, ou créez-en un en quelques secondes.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary),
                child: const Text('Se connecter'),
              ),
              OutlinedButton(
                onPressed: onRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Text(
            'BioDigit • BioSmart Africa',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monitoring des biodigesteurs au Burkina Faso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HighlightItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, height: 1.45, color: Colors.white.withValues(alpha: 0.88))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardData {
  final IconData icon;
  final String title;
  final String description;

  _FeatureCardData(this.icon, this.title, this.description);
}