import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [AppTheme.primaryContainer, cs.surface],
            stops: const [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final circleSize = (w * 0.55).clamp(140.0, 280.0);
              final iconSize = (circleSize * 0.43).clamp(48.0, 120.0);
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight * 0.7,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _floatAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatAnimation.value),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                                        blurRadius: 40,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                                      child: Icon(Icons.eco, size: iconSize, color: AppTheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildSensorTag(Icons.sensors, 'Live Monitoring', AppTheme.primary),
                                  _buildSensorTag(Icons.eco, 'Clean Energy', AppTheme.secondary),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.energy_savings_leaf, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      'BioDigit',
                                      style: TextStyle(
                                        fontSize: (w * 0.07).clamp(20.0, 28.0),
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Smart Biodigester Monitoring System\nfor Burkina Faso.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (w * 0.04).clamp(13.0, 16.0),
                                  height: 1.5,
                                  letterSpacing: 0.5,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'POWERED BY IOT',
                                style: TextStyle(fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w500, color: cs.outline),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 96,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: cs.outlineVariant,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.33,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.landing),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Get Started'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'v2.4.0 • Plateau Central, Burkina Faso',
                          style: TextStyle(fontSize: 11, color: cs.outlineVariant, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
