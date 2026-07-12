import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../routes.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/common_widgets.dart';
import '../models/biodigester_model.dart';
import '../services/providers.dart';

class LiveMonitoring extends StatefulWidget {
  const LiveMonitoring({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<LiveMonitoring> createState() => _LiveMonitoringState();
}

class _LiveMonitoringState extends State<LiveMonitoring> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorProv = context.watch<SensorProvider>();

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.containerPadding,
          24,
          AppTheme.containerPadding,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Bar
            _buildConnectionBar(sensorProv),
            const SizedBox(height: 12),

            // Supabase Status
            const SupabaseStatusCard(),
            const SizedBox(height: 24),

            // Live Feed Section
            _buildLiveFeed(sensorProv),
            const SizedBox(height: 24),

            // Gauges Grid
            _buildGaugesGrid(),
            const SizedBox(height: 32),

            // Maintenance préventive
            _buildPredictiveMaintenance(),
            const SizedBox(height: 32),

            // Sensor Health
            _buildSensorHealth(),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBackButton ? null : const BottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        color: AppTheme.surface.withValues(alpha: 0.8),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.containerPadding,
              vertical: AppTheme.baseSpacing,
            ),
            child: Row(
              children: [
                if (widget.showBackButton)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryContainer,
                  child: Icon(Icons.eco, color: AppTheme.onPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'BioDigit',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.primaryFixed : AppTheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.notifications),
                  icon: Icon(Icons.notifications,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionBar(SensorProvider sensorProv) {
    final isOnline = sensorProv.isOnline;
    final isLoading = sensorProv.isLoading;
    final isFrench = context.watch<LocaleProvider>().isFrench;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOnline ? cs.surfaceContainerLow : cs.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.memory, color: isOnline ? AppTheme.primary : AppTheme.error, size: 18),
            const SizedBox(width: 8),
            Text(
              'ESP8266: ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              isOnline ? (isFrench ? 'Connecté' : 'Connected') : (isFrench ? 'Hors ligne' : 'Offline'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isOnline ? AppTheme.primaryContainer : AppTheme.error,
              ),
            ),
            const SizedBox(width: 16),
            Container(width: 1, height: 16, color: cs.outlineVariant),
            const SizedBox(width: 16),
            Icon(Icons.signal_cellular_alt,
                color: isOnline ? AppTheme.primary : AppTheme.error, size: 18),
            const SizedBox(width: 8),
            Text(
              isOnline ? 'Signal: Excellent' : 'Signal: Lost',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.battery_5_bar,
                      color: AppTheme.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    isLoading ? 'Sync...' : '92%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildLiveFeed(SensorProvider sensorProv) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          Center(
            child: sensorProv.isLoading
                ? const CircularProgressIndicator()
                : Icon(
                    Icons.videocam,
                    size: 80,
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE MONITORING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central Digester Unit 01',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sensorProv.latestReading == null ? 'Awaiting live feed...' : 'Active since 04:30 AM',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugesGrid() {
    return Consumer<SensorProvider>(
      builder: (context, sensorProv, _) {
        final reading = sensorProv.latestReading;
        final isFrench = context.watch<LocaleProvider>().isFrench;
        final nowText = isFrench ? 'Maintenant' : 'Now';
        final gauges = [
          _GaugeData(
            isFrench ? 'Température' : 'Temperature',
            reading != null ? reading.temperature.toStringAsFixed(1) : '--',
            '\u00b0C',
            AppTheme.primary,
            Icons.thermostat,
            reading != null ? ((reading.temperature - 25) / 15).clamp(0.0, 1.0) : 0.0,
            reading?.temperatureTrend ?? 'stable',
            reading != null ? nowText : '--',
          ),
          _GaugeData(
            isFrench ? 'Pression' : 'Pressure',
            reading != null ? reading.pressure.toStringAsFixed(2) : '--',
            'BAR',
            AppTheme.tertiary,
            Icons.speed,
            reading != null ? ((reading.pressure - 0.8) / 0.7).clamp(0.0, 1.0) : 0.0,
            reading?.pressureTrend ?? 'stable',
            reading != null ? nowText : '--',
          ),
          _GaugeData(
            isFrench ? 'Méthane' : 'Methane',
            reading != null ? reading.methane.toStringAsFixed(0) : '--',
            'ppm',
            AppTheme.primaryContainer,
            Icons.gas_meter,
            reading != null ? ((reading.methane - 150) / 350).clamp(0.0, 1.0) : 0.0,
            reading?.methaneTrend ?? 'stable',
            reading != null ? nowText : '--',
          ),
          _GaugeData(
            isFrench ? 'Niveau' : 'Level',
            reading != null ? reading.slurryLevel.toStringAsFixed(1) : '--',
            '%',
            AppTheme.secondary,
            Icons.inventory_2,
            reading != null ? (reading.slurryLevel / 100).clamp(0.0, 1.0) : 0.0,
            reading?.slurryTrend ?? 'stable',
            reading != null ? nowText : '--',
          ),
        ];
  
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: gauges.length,
          itemBuilder: (context, index) {
            return _buildGaugeCard(gauges[index]);
          },
        );
      },
    );
  }

  Widget _buildGaugeCard(_GaugeData data) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(90, 90),
                  painter: _CircularProgressPainter(
                    progress: data.progress,
                    color: data.color,
                    strokeWidth: 7,
                    bgColor: cs.surfaceContainerHigh,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: data.color,
                      ),
                    ),
                    Text(
                      data.unit,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, color: data.color, size: 16),
              const SizedBox(width: 4),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrendIndicator(trend: data.trend),
              const SizedBox(width: 4),
              Text(
                data.lastUpdate,
                style: TextStyle(fontSize: 9, color: cs.outlineVariant),
              ),
            ],
          ),
        ],
      ),
    );});
  }

  Widget _buildPredictiveMaintenance() {
    final cs = Theme.of(context).colorScheme;
    final isFrench = context.watch<LocaleProvider>().isFrench;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFrench ? 'Maintenance préventive' : 'Preventive Maintenance',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full maintenance list when available
              },
              child: Text(isFrench ? 'Voir tout' : 'View all'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...MaintenanceItem.mockMaintenance.take(3).map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 10, color: cs.outlineVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${isFrench ? 'Échéance' : 'Due'}: ${item.dueDate}',
                          style: TextStyle(fontSize: 10, color: cs.outlineVariant),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.priority.toUpperCase(),
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSensorHealth() {
    return Consumer<SensorProvider>(
      builder: (context, sensorProv, _) {
        final cs = Theme.of(context).colorScheme;
        final isFrench = context.watch<LocaleProvider>().isFrench;
        final reading = sensorProv.latestReading;
        final updatedText = isFrench ? 'Mis à jour maintenant' : 'Updated now';
        final waitingText = isFrench ? 'En attente de données...' : 'Waiting for data...';
        final normalText = isFrench ? 'Normal' : 'Normal';
        final attentionText = isFrench ? 'Attention' : 'Warning';
        final sensors = [
          {
            'name': isFrench ? 'Capteur de température' : 'Temperature Sensor',
            'status': reading != null && reading.temperature >= 25 && reading.temperature <= 40 ? normalText : attentionText,
            'detail': reading != null
                ? '${reading.temperature.toStringAsFixed(1)}\u00b0C - $updatedText'
                : waitingText,
            'icon': reading != null && reading.temperature >= 25 && reading.temperature <= 40 ? Icons.check_circle : Icons.warning,
            'color': reading != null && reading.temperature >= 25 && reading.temperature <= 40 ? AppTheme.primary : AppTheme.error,
          },
          {
            'name': isFrench ? 'Capteur de méthane' : 'Methane Sensor',
            'status': reading != null && reading.methane >= 150 && reading.methane <= 500 ? normalText : attentionText,
            'detail': reading != null
                ? '${reading.methane.toStringAsFixed(0)} ppm - $updatedText'
                : waitingText,
            'icon': reading != null && reading.methane >= 150 && reading.methane <= 500 ? Icons.check_circle : Icons.warning,
            'color': reading != null && reading.methane >= 150 && reading.methane <= 500 ? AppTheme.primary : AppTheme.error,
          },
          {
            'name': isFrench ? 'Capteur de pression' : 'Pressure Sensor',
            'status': reading != null && reading.pressure >= 0.8 && reading.pressure <= 1.5 ? normalText : attentionText,
            'detail': reading != null
                ? '${reading.pressure.toStringAsFixed(2)} bar - $updatedText'
                : waitingText,
            'icon': reading != null && reading.pressure >= 0.8 && reading.pressure <= 1.5 ? Icons.check_circle : Icons.info,
            'color': reading != null && reading.pressure >= 0.8 && reading.pressure <= 1.5 ? AppTheme.primary : AppTheme.secondary,
          },
          {
            'name': isFrench ? 'Capteur ultrason' : 'Ultrasonic Sensor',
            'status': reading != null && reading.slurryLevel >= 20 && reading.slurryLevel <= 90 ? normalText : attentionText,
            'detail': reading != null
                ? '${reading.slurryLevel.toStringAsFixed(1)}% - $updatedText'
                : waitingText,
            'icon': reading != null && reading.slurryLevel >= 20 && reading.slurryLevel <= 90 ? Icons.check_circle : Icons.warning,
            'color': reading != null && reading.slurryLevel >= 20 && reading.slurryLevel <= 90 ? AppTheme.primary : AppTheme.error,
          },
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFrench ? 'Santé des capteurs' : 'Sensor Health',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              updatedText,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sensors.map((sensor) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (sensor['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(sensor['icon'] as IconData,
                      color: sensor['color'] as Color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        sensor['detail'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (sensor['status'] == normalText)
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    (sensor['status'] as String).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: (sensor['status'] == normalText)
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFFF57F17),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
    },
    );
  }
}

class _GaugeData {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final double progress;
  final String trend;
  final String lastUpdate;

  const _GaugeData(this.label, this.value, this.unit, this.color, this.icon, this.progress, this.trend, this.lastUpdate);
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color bgColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
