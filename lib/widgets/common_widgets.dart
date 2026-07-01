import 'package:flutter/material.dart';
import '../utils/trend_style.dart';
import '../theme/app_theme.dart';
import '../models/biodigester_model.dart';

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
        backgroundColor: AppTheme.surfaceContainer,
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
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
              if (sensorModel != null && sensorModel!.isNotEmpty) ...[                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHigh,
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
                style: const TextStyle(
                  fontSize: 28,
                  height: 36 / 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
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
              style: const TextStyle(fontSize: 10, color: AppTheme.outline),
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
    final IconData icon = trendIcon(trend);
    Color color;
    switch (trend) {
      case 'rising':
        color = const Color(0xFF1B5E20);
        break;
      case 'falling':
        color = AppTheme.error;
        break;
      default:
        color = AppTheme.outline;
    }
    return Icon(icon, size: 16, color: color);
  }
}

/// ESP32 Controller Status Card
class ESP32StatusCard extends StatelessWidget {
  const ESP32StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final esp = ESP32Status.mockStatus;
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
              const Expanded(
                child: Text(
                  'ESP32 Controller',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  esp.status.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _espItem(Icons.wifi, 'Wi-Fi Signal', esp.wifiStrength),
              const SizedBox(width: 16),
              _espItem(Icons.sync, 'Last Sync', esp.lastSync),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _espItem(Icons.settings_applications, 'Firmware', esp.firmwareVersion),
              const SizedBox(width: 16),
              _espItem(Icons.battery_charging_full, 'Battery', '${esp.batteryLevel}%'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _espItem(Icons.lan, 'IP Address', esp.ipAddress),
              const SizedBox(width: 16),
              _espItem(Icons.timer, 'Uptime', esp.uptime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _espItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Firebase Connection Status Card
class FirebaseStatusCard extends StatelessWidget {
  const FirebaseStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final fb = FirebaseStatus.mockStatus;
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
              const Expanded(
                child: Text(
                  'Firebase Realtime Database',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  fb.connectionStatus.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF262F89)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _fbItem(Icons.cloud_done, 'Cloud Sync', fb.cloudSync),
              const SizedBox(width: 16),
              _fbItem(Icons.upload, 'Last Upload', fb.lastUpload),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _fbItem(Icons.verified, 'Data Integrity', fb.dataIntegrity),
              const SizedBox(width: 16),
              _fbItem(Icons.storage, 'Records Today', '${fb.recordsToday}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fbItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurface), overflow: TextOverflow.ellipsis),
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

    // ESP32 box (bottom right)
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
    final bio = BiodigesterModel.mockBiodigester;
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
            'BIOGAS PRODUCTION',
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
                '${bio.todayProduction}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'm³/day',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _prodStat('Weekly', '${bio.weeklyProduction} m³'),
              const SizedBox(width: 16),
              _prodStat('Monthly', '${bio.monthlyProduction} m³'),
              const SizedBox(width: 16),
              _prodStat('Yearly', '${bio.yearlyProduction} m³'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppTheme.onPrimaryContainer),
              const SizedBox(width: 4),
              Text(
                '8% increase from last week · Efficiency ${bio.efficiency}%',
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
    final bio = BiodigesterModel.mockBiodigester;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Energy & Environmental Impact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _impactItem(Icons.bolt, 'Energy Generated', '${bio.energyGenerated} kWh', AppTheme.primary),
              const SizedBox(width: 12),
              _impactItem(Icons.eco, 'CO₂ Reduction', '${bio.co2Reduction.toInt()} kg', const Color(0xFF2E7D32)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _impactItem(Icons.percent, 'Efficiency', '${bio.efficiency}%', AppTheme.tertiary),
              const SizedBox(width: 12),
              _impactItem(Icons.storage, 'Capacity', '${bio.capacity} m³', AppTheme.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline)),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
