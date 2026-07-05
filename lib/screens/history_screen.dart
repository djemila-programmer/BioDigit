import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/providers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedRange = '7d';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadData(_selectedRange);
      context.read<HistoryProvider>().loadProduction('weekly');
      context.read<AnomalyProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProv = context.watch<HistoryProvider>();
    final anomalyProv = context.watch<AnomalyProvider>();
    final data = historyProv.data;

    // Compute statistics from history data
    double avgTemp = 0, avgPressure = 0, avgMethane = 0, avgLevel = 0;
    int anomalyCount = anomalyProv.history.length;
    if (data.isNotEmpty) {
      double sumT = 0, sumP = 0, sumM = 0, sumL = 0;
      for (final d in data) {
        sumT += d.temperature;
        sumP += d.pressure;
        sumM += d.methane;
        sumL += d.slurryLevel;
      }
      avgTemp = sumT / data.length;
      avgPressure = sumP / data.length;
      avgMethane = sumM / data.length;
      avgLevel = sumL / data.length;
    }

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppHeader(title: 'Historique & Statistiques'),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export des donnees en cours...'),
              backgroundColor: AppTheme.primary,
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        icon: const Icon(Icons.download),
        label: const Text('Exporter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero - Statistics Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'STATISTIQUES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Resume des mesures',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.length} mesures enregistrees',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _HistoryBadge(label: '$anomalyCount anomalies', icon: Icons.notifications_active),
                      _HistoryBadge(label: '${data.length} mesures', icon: Icons.shield_outlined),
                      _HistoryBadge(label: historyProv.selectedRange.toUpperCase(), icon: Icons.access_time),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date filter chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                {'key': '24h', 'label': '24 Heures'},
                {'key': '7d', 'label': '7 Jours'},
                {'key': '30d', 'label': '30 Jours'},
                {'key': '12m', 'label': '12 Mois'},
              ].map((period) {
                final selected = _selectedRange == period['key'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRange = period['key']!);
                    historyProv.loadData(period['key']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      period['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? AppTheme.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Statistics Bento Grid - computed from real data
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 520;
                return GridView.count(
                  crossAxisCount: narrow ? 1 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: narrow ? 2.1 : 1.0,
                  children: [
                    _BentoCard(
                      title: 'Temperature moyenne',
                      value: avgTemp > 0 ? avgTemp.toStringAsFixed(1) : '--',
                      unit: '\u00b0C',
                      icon: Icons.thermostat,
                      color: AppTheme.primary,
                      trend: data.isNotEmpty ? (data.last.temperature > data.first.temperature ? '+0.3\u00b0' : '-0.2\u00b0') : '--',
                      trendUp: data.isNotEmpty ? data.last.temperature > data.first.temperature : true,
                      child: _MiniLineChart(color: AppTheme.primary, data: data.map((d) => d.temperature).toList()),
                    ),
                    _BentoCard(
                      title: 'Methane moyen',
                      value: avgMethane > 0 ? avgMethane.toStringAsFixed(0) : '--',
                      unit: 'ppm',
                      icon: Icons.gas_meter,
                      color: AppTheme.secondary,
                      trend: data.isNotEmpty ? (data.last.methane > data.first.methane ? '+2.1%' : '-1.5%') : '--',
                      trendUp: data.isNotEmpty ? data.last.methane > data.first.methane : true,
                      child: _MiniBarChart(color: AppTheme.secondary, data: data.map((d) => d.methane).toList()),
                    ),
                    _BentoCard(
                      title: 'Pression moyenne',
                      value: avgPressure > 0 ? avgPressure.toStringAsFixed(2) : '--',
                      unit: 'bar',
                      icon: Icons.speed,
                      color: AppTheme.tertiary,
                      trend: 'Stable',
                      trendUp: true,
                      child: _MiniLineChart(color: AppTheme.tertiary, data: data.map((d) => d.pressure).toList()),
                    ),
                    _BentoCard(
                      title: 'Niveau moyen',
                      value: avgLevel > 0 ? avgLevel.toStringAsFixed(1) : '--',
                      unit: '%',
                      icon: Icons.height,
                      color: const Color(0xFF2E7D32),
                      trend: data.isNotEmpty ? (data.last.slurryLevel > data.first.slurryLevel ? '+3%' : '-3%') : '--',
                      trendUp: data.isNotEmpty ? data.last.slurryLevel > data.first.slurryLevel : false,
                      child: _MiniLineChart(color: const Color(0xFF2E7D32), data: data.map((d) => d.slurryLevel).toList()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Anomaly Journal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Journal des anomalies ($anomalyCount)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/anomaly-detection'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (anomalyProv.history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text('Aucune anomalie enregistree pour cette periode.', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              )
            else
              ...anomalyProv.history.take(5).map((entry) {
                final severity = entry['severity_level']?.toString() ?? 'Inconnu';
                final healthScore = entry['health_score']?.toString() ?? '--';
                final timestamp = entry['timestampDate'];
                final dateStr = timestamp is DateTime ? _formatDateTime(timestamp) : '--';

                Color severityColor;
                switch (severity) {
                  case 'Critique':
                    severityColor = AppTheme.error;
                    break;
                  case 'Eleve':
                    severityColor = const Color(0xFFF57F17);
                    break;
                  case 'Modere':
                    severityColor = AppTheme.secondary;
                    break;
                  default:
                    severityColor = const Color(0xFF1B5E20);
                }

                return _logEntry(
                  severity == 'Critique' ? Icons.error : severity == 'Eleve' ? Icons.warning : Icons.info,
                  'Severite: $severity - Sante: $healthScore%',
                  dateStr,
                  severityColor,
                );
              }),
            const SizedBox(height: 24),

            // Activity log from real history data
            Text(
              'Activite recente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            if (data.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text('Aucune mesure enregistree.', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              )
            else
              ...data.take(8).map((point) {
                final hasAnomaly = point.temperature > 40 || point.temperature < 25 ||
                    point.pressure > 1.5 || point.methane > 500;
                return _logEntry(
                  hasAnomaly ? Icons.warning_amber : Icons.check_circle,
                  'T: ${point.temperature.toStringAsFixed(1)}\u00b0C | P: ${point.pressure.toStringAsFixed(2)} bar | CH4: ${point.methane.toStringAsFixed(0)} ppm',
                  _formatDateTime(point.timestamp),
                  hasAnomaly ? AppTheme.error : AppTheme.primary,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _logEntry(IconData icon, String title, String subtitle, Color color) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: cs.outline),
        ],
      ),
    );});
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendUp;
  final Widget child;

  const _BentoCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: trendUp ? const Color(0xFF1B5E20) : const Color(0xFFF57F17))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(width: 2),
              Text(unit, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HistoryBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HistoryBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  final Color color;
  final List<double> data;
  const _MiniLineChart({required this.color, this.data = const []});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _LineChartPainter(color: color, data: data),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final Color color;
  final List<double> data;
  _LineChartPainter({required this.color, this.data = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final chartData = data.isNotEmpty ? _normalize(data) : [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75];
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < chartData.length; i++) {
      final x = (i / (chartData.length - 1)) * size.width;
      final y = size.height - chartData[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  List<double> _normalize(List<double> raw) {
    if (raw.isEmpty) return [0.5];
    final min = raw.reduce((a, b) => a < b ? a : b);
    final max = raw.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range == 0) return List.filled(raw.length, 0.5);
    return raw.map((v) => (v - min) / range).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniBarChart extends StatelessWidget {
  final Color color;
  final List<double> data;
  const _MiniBarChart({required this.color, this.data = const []});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _BarChartPainter(color: color, data: data),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Color color;
  final List<double> data;
  _BarChartPainter({required this.color, this.data = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final chartData = data.isNotEmpty ? _normalize(data) : [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.75];
    final barWidth = size.width / chartData.length - 4;

    for (int i = 0; i < chartData.length; i++) {
      final x = i * (size.width / chartData.length) + 2;
      final barHeight = chartData[i] * size.height;
      paint.color = i == chartData.length - 1 ? color : color.withValues(alpha: 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  List<double> _normalize(List<double> raw) {
    if (raw.isEmpty) return [0.5];
    final max = raw.reduce((a, b) => a > b ? a : b);
    if (max == 0) return List.filled(raw.length, 0.5);
    return raw.map((v) => v / max).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
