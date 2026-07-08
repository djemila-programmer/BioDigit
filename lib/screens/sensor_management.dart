import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/sensor_model.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/common_widgets.dart';

class SensorManagement extends StatelessWidget {
  const SensorManagement({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
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
        title: Text('Sensor Management', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      bottomNavigationBar: showBackButton ? null : const BottomNavBar(currentIndex: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('4', 'Active Sensors', AppTheme.onPrimary),
                  Container(width: 1, height: 32, color: AppTheme.onPrimary.withValues(alpha: 0.3)),
                  _summaryItem('2', 'Need Attention', AppTheme.secondaryContainer),
                  Container(width: 1, height: 32, color: AppTheme.onPrimary.withValues(alpha: 0.3)),
                  _summaryItem('98%', 'Avg Uptime', AppTheme.primaryFixed),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sensor Array',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...SensorModel.mockSensors.map((sensor) => _SensorCard(sensor: sensor)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'Maintenance Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sensor scheduling coming soon')),
                          ),
                          icon: const Icon(Icons.build),
                          label: const Text('Schedule'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('QR sensor scanning coming soon')),
                          ),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Sensor'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8), letterSpacing: 0.3)),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final SensorModel sensor;
  const _SensorCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sensor.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(sensor.icon, color: sensor.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      sensor.modelNumber,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: sensor.status, type: sensor.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sensor.value.toStringAsFixed(sensor.value >= 100 ? 0 : 1),
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
              const SizedBox(width: 4),
              Text(
                sensor.unit,
                style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              // Sparkline
              SizedBox(
                width: 80,
                height: 32,
                child: CustomPaint(
                  painter: _SparklinePainter(
                    data: sensor.sparklineData,
                    color: sensor.iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Battery and signal
          Row(
            children: [
              _infoChip(Icons.battery_charging_full, '${sensor.batteryLevel.toInt()}%',
                  sensor.batteryLevel > 20 ? AppTheme.primary : AppTheme.error),
              const SizedBox(width: 8),
              _infoChip(Icons.signal_cellular_alt, sensor.signalQuality, AppTheme.tertiary),
              const SizedBox(width: 8),
              _infoChip(
                sensor.trend == 'rising' ? Icons.trending_up : sensor.trend == 'falling' ? Icons.trending_down : Icons.trending_flat,
                sensor.trend,
                sensor.trend == 'falling' ? AppTheme.error : AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Calibration and maintenance info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 14, color: AppTheme.outline),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Calibration', style: TextStyle(fontSize: 9, color: cs.outline)),
                            Text(sensor.lastCalibration, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: cs.outlineVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.build, size: 14, color: AppTheme.outline),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next Maintenance', style: TextStyle(fontSize: 9, color: cs.outline)),
                            Text(sensor.nextMaintenance, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: cs.onSurface)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensor calibration coming soon')),
              ),
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Calibrate Sensor'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
