import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/providers.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String type; // normal, warning, critical, stable, active, info

  const StatusBadge({super.key, required this.label, required this.type});

  Color get _bgColor {
    switch (type) {
      case 'normal':
      case 'active':
        return const Color(0xFFE8F5E9);
      case 'warning':
      case 'stable':
        return const Color(0xFFFFF8E1);
      case 'critical':
        return const Color(0xFFFFDAD6);
      case 'info':
        return AppTheme.surfaceContainerHighest;
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get _textColor {
    switch (type) {
      case 'normal':
      case 'active':
        return const Color(0xFF1B5E20);
      case 'warning':
        return const Color(0xFFF57F17);
      case 'stable':
        return AppTheme.secondary;
      case 'critical':
        return AppTheme.error;
      case 'info':
        return AppTheme.outline;
      default:
        return const Color(0xFF1B5E20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class ProgressIndicatorBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const ProgressIndicatorBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final String status;
  final double progress;
  final String? trend;
  final String? lastUpdate;
  final String? sensorModel;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.progress,
    this.trend,
    this.lastUpdate,
    this.sensorModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              StatusBadge(
                label: status,
                type: status.toLowerCase(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
              if (sensorModel != null && sensorModel!.isNotEmpty) ...[                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sensorModel!,
                    style: const TextStyle(fontSize: 9, color: AppTheme.outline, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (trend != null) ...[                const SizedBox(width: 8),
                TrendIndicator(trend: trend!),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ProgressIndicatorBar(progress: progress, color: iconColor),
          if (lastUpdate != null) ...[            const SizedBox(height: 4),
            Text(
              'Updated $lastUpdate',
              style: TextStyle(fontSize: 10, color: AppTheme.subtext(context)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Trend indicator arrow widget
class TrendIndicator extends StatelessWidget {
  final String trend;
  const TrendIndicator({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (trend) {
      case 'rising':
        icon = Icons.trending_up;
        color = const Color(0xFF1B5E20);
        break;
      case 'falling':
        icon = Icons.trending_down;
        color = AppTheme.error;
        break;
      default:
        icon = Icons.trending_flat;
        color = AppTheme.outline;
    }
    return Icon(icon, size: 16, color: color);
  }
  
}

/// ESP8266 Controller Status Card
class ESP8266StatusCard extends StatelessWidget {
  const ESP8266StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    return Consumer<SensorProvider>(
      builder: (context, sensorProv, _) {
        final esp = sensorProv.esp32Status;
        final isConnected = sensorProv.isOnline;
        final isSimulation = sensorProv.isSimulation;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.05),
                AppTheme.primaryContainer.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.memory, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ESP8266 Controller',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSimulation ? const Color(0xFFFFF8E1) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      isSimulation ? 'SIMULATION' : (isConnected ? (isFrench ? 'CONNECTÉ' : 'CONNECTED') : (isFrench ? 'DÉCONNECTÉ' : 'DISCONNECTED')),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSimulation ? const Color(0xFFF57F17) : const Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _espItem(context, Icons.wifi, isFrench ? 'Signal Wi-Fi' : 'Wi-Fi Signal', isConnected ? 'Excellent' : 'N/A'),
                  const SizedBox(width: 16),
                  _espItem(context, Icons.sync, isFrench ? 'Dernière synchro' : 'Last Sync', isConnected ? (isFrench ? 'Maintenant' : 'Now') : '--'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _espItem(context, Icons.settings_applications, 'Firmware', esp?.firmwareVersion ?? 'v2.4.1-bf'),
                  const SizedBox(width: 16),
                  _espItem(context, Icons.battery_charging_full, isFrench ? 'Batterie' : 'Battery', esp != null ? '${esp.batteryLevel}%' : 'N/A'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _espItem(context, Icons.lan, isFrench ? 'Adresse IP' : 'IP Address', esp?.ipAddress ?? '192.168.1.100'),
                  const SizedBox(width: 16),
                  _espItem(context, Icons.timer, 'Uptime', esp?.uptime ?? '--'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _espItem(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Supabase Connection Status Card
class SupabaseStatusCard extends StatelessWidget {
  const SupabaseStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    return Consumer<SensorProvider>(
      builder: (context, sensorProv, _) {
        final isConnected = sensorProv.isOnline;
        final isSimulation = sensorProv.isSimulation;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.tertiary.withValues(alpha: 0.05),
                AppTheme.tertiaryContainer.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cloud_sync, color: AppTheme.tertiary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Supabase Realtime',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isConnected ? const Color(0xFFE0E0FF) : const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      (isConnected ? (isFrench ? 'CONNECTÉ' : 'CONNECTED') : (isFrench ? 'DÉCONNECTÉ' : 'DISCONNECTED')),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isConnected ? const Color(0xFF262F89) : AppTheme.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _fbItem(context, Icons.cloud_done, isFrench ? 'Synchro Cloud' : 'Cloud Sync', isConnected ? (isFrench ? 'Actif' : 'Active') : (isFrench ? 'Inactif' : 'Inactive')),
                  const SizedBox(width: 16),
                  _fbItem(context, Icons.upload, isFrench ? 'Mode' : 'Mode', isSimulation ? 'Simulation' : (isFrench ? 'Temps réel' : 'Real-time')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _fbItem(context, Icons.verified, isFrench ? 'Intégrité' : 'Integrity', isConnected ? (isFrench ? '100% Vérifié' : '100% Verified') : '--'),
                  const SizedBox(width: 16),
                  _fbItem(context, Icons.storage, isFrench ? 'Source' : 'Source', isSimulation ? (isFrench ? 'Jumeau numérique' : 'Digital Twin') : 'ESP8266'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fbItem(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Biodigester Visual Illustration Widget
class BiodigesterVisual extends StatelessWidget {
  final double height;
  const BiodigesterVisual({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.85),
            AppTheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Biodigester illustration
          Positioned.fill(
            child: CustomPaint(
              painter: _BiodigesterIllustrationPainter(),
            ),
          ),
          // System health badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('SYSTEM ONLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                ],
              ),
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYSTEM HEALTH',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Excellent',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Biogas production
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('BIOGAS', style: TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, letterSpacing: 1, fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('12.5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      const SizedBox(width: 2),
                      Text('m³/day', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiodigesterIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Main digester tank (center)
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.15, size.width * 0.3, size.height * 0.7),
      const Radius.circular(16),
    );
    canvas.drawRRect(tankRect, whitePaint);
    canvas.drawRRect(tankRect, strokePaint);

    // Gas dome on top of tank
    final domePath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.40, size.height * 0.0,
        size.width * 0.48, size.height * 0.15,
      );
    canvas.drawPath(domePath, whitePaint);
    canvas.drawPath(domePath, strokePaint);

    // Slurry level inside tank
    final slurryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final slurryLevel = size.height * 0.55;
    final slurryRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.26, slurryLevel, size.width * 0.28, size.height * 0.29),
      const Radius.circular(12),
    );
    canvas.drawRRect(slurryRect, slurryPaint);

    // Gas pipeline (right side)
    final pipePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final pipePath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.25)
      ..lineTo(size.width * 0.72, size.height * 0.25)
      ..lineTo(size.width * 0.72, size.height * 0.55);
    canvas.drawPath(pipePath, pipePaint);

    // Gas storage dome (right)
    final storageOval = Rect.fromCenter(
      center: Offset(size.width * 0.72, size.height * 0.65),
      width: size.width * 0.18,
      height: size.height * 0.25,
    );
    canvas.drawOval(storageOval, whitePaint);
    canvas.drawOval(storageOval, strokePaint);

    // Input pipe (left side)
    final inputPath = Path()
      ..moveTo(size.width * 0.05, size.height * 0.4)
      ..lineTo(size.width * 0.25, size.height * 0.45);
    canvas.drawPath(inputPath, pipePaint);

    // Output pipe (bottom left)
    final outputPath = Path()
      ..moveTo(size.width * 0.30, size.height * 0.85)
      ..lineTo(size.width * 0.15, size.height * 0.95);
    canvas.drawPath(outputPath, pipePaint);

    // Sensor dots on the tank
    final sensorPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.35), 3, sensorPaint);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.55), 3, sensorPaint);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.70), 3, sensorPaint);

    // ESP8266 box (bottom right)
    final espRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.30, size.width * 0.12, size.height * 0.15),
      const Radius.circular(4),
    );
    canvas.drawRRect(espRect, strokePaint);
    // Antenna
    canvas.drawLine(
      Offset(size.width * 0.84, size.height * 0.30),
      Offset(size.width * 0.84, size.height * 0.18),
      strokePaint,
    );
    canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.17), 3, sensorPaint);

    // Labels
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'DIGESTER',
        style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.33, size.height * 0.42));

    final gasLabel = TextPainter(
      text: TextSpan(
        text: 'GAS',
        style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    gasLabel.paint(canvas, Offset(size.width * 0.685, size.height * 0.62));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Biogas Production Summary Card
class BiogasProductionCard extends StatelessWidget {
  const BiogasProductionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    return Consumer<HistoryProvider>(
      builder: (context, historyProv, _) {
        final prod = historyProv.production;
        final volume = prod?.volume ?? 0;
        final efficiency = prod?.efficiency ?? 0;
        final energy = prod?.energyGenerated ?? 0;
        final co2 = prod?.co2Reduction ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFrench ? 'PRODUCTION DE BIOGAZ' : 'BIOGAS PRODUCTION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onPrimaryContainer.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    volume.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFrench ? 'm\u00b3/jour' : 'm\u00b3/day',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _prodStat(isFrench ? 'Énergie' : 'Energy', '${energy.toStringAsFixed(1)} kWh'),
                  _prodStat(isFrench ? 'CO2 réduit' : 'CO2 reduced', '${co2.toStringAsFixed(2)} kg'),
                  _prodStat(isFrench ? 'Efficacité' : 'Efficiency', '${efficiency.toStringAsFixed(1)}%'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 16, color: AppTheme.onPrimaryContainer),
                  const SizedBox(width: 4),
                  Text(
                    isFrench
                        ? '${prod?.readingCount ?? 0} mesures - Période: ${prod?.period ?? '--'}'
                        : '${prod?.readingCount ?? 0} readings - Period: ${prod?.period ?? '--'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _prodStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.onPrimaryContainer.withValues(alpha: 0.7), letterSpacing: 0.5)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onPrimaryContainer)),
      ],
    );
  }
}

/// Energy and Environmental Impact Card
class EnergyImpactCard extends StatelessWidget {
  const EnergyImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isFrench = context.watch<LocaleProvider>().isFrench;
    return Consumer<HistoryProvider>(
      builder: (context, historyProv, _) {
        final prod = historyProv.production;
        final energy = prod?.energyGenerated ?? 0;
        final co2 = prod?.co2Reduction ?? 0;
        final efficiency = prod?.efficiency ?? 0;
        final readingCount = prod?.readingCount ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFrench ? 'Impact énergétique & environnemental' : 'Energy & Environmental Impact',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _impactItem(context, Icons.bolt, isFrench ? 'Énergie générée' : 'Energy generated', '${energy.toStringAsFixed(1)} kWh', AppTheme.primary),
                  _impactItem(context, Icons.eco, isFrench ? 'Réduction CO2' : 'CO2 reduction', '${co2.toStringAsFixed(2)} kg', const Color(0xFF2E7D32)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _impactItem(context, Icons.percent, isFrench ? 'Efficacité' : 'Efficiency', '${efficiency.toStringAsFixed(1)}%', AppTheme.tertiary),
                  _impactItem(context, Icons.storage, isFrench ? 'Mesures' : 'Readings', '$readingCount', AppTheme.secondary),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _impactItem(BuildContext context, IconData icon, String label, String value, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
