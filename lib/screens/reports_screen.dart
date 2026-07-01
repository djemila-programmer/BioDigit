import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/context_extensions.dart';
import '../widgets/app_header.dart';
import '../services/pdf_service.dart';
import '../services/farm_service.dart';
import '../services/history_service.dart';
import '../services/anomaly_service.dart';
import '../services/providers.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final String _selectedPeriod = 'weekly';
  bool _isGenerating = false;

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    try {
      final farmService = context.read<FarmService>();
      final historyService = context.read<HistoryService>();
      final anomalyService = context.read<AnomalyService>();
      final pdfService = context.read<PdfService>();
      final sensorProv = context.read<SensorProvider>();

      final farms = await farmService.getUserFarms();
      final farm = farms.isNotEmpty
          ? farms.first
          : FarmData(id: '', ownerId: '', name: 'Ferme BioSmart', location: 'Plateau Central, Burkina Faso',
              biodigesterType: 'Fixed-dome', biodigesterCapacity: 10);

      final production = await historyService.getProductionSummary(_selectedPeriod);
      final history = await historyService.getLast7Days();
      final reading = sensorProv.latestReading;
      final anomaly = reading != null
          ? anomalyService.analyze(reading)
          : AnomalyReport(healthScore: 0, riskScore: 0, severityLevel: 'N/A',
              predictionConfidence: 0, sensorAnomalies: 0, recommendedActions: 0,
              sensorResults: [], actions: [], timestamp: DateTime.now());

      final pdf = await pdfService.generateReport(
        farm: farm,
        production: production,
        anomaly: anomaly,
        historyData: history,
        period: _selectedPeriod,
      );

      final fileName = 'biodigester_report_${_selectedPeriod}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = await pdfService.savePdf(pdf, fileName);

      if (mounted) {
        context.showSnackBar('Rapport généré: $filePath');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Erreur: ${e.toString()}');
      }
    }
    if (mounted) setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AppHeader(title: 'Reports', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report summary
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
                  const Text('Biogas Production Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Weekly Summary · Jan 15 - Jan 21', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _reportStat('87.5', 'm³ Total', Colors.white),
                      _reportStat('12.5', 'm³/day Avg', AppTheme.primaryFixed),
                      _reportStat('+8%', 'vs Last Week', AppTheme.primaryFixed),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Production chart placeholder
            Text('Production Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _ProductionChartPainter(),
              ),
            ),
            const SizedBox(height: 24),
            // Key metrics grid
            Text('Key Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _metricTile(Icons.thermostat, 'Avg Temperature', '38.2°C', '±0.5°C', AppTheme.primary),
                _metricTile(Icons.speed, 'Avg Pressure', '1.05 bar', 'Stable', AppTheme.tertiary),
                _metricTile(Icons.gas_meter, 'Methane Purity', '64.2%', '+1.8%', AppTheme.secondary),
                _metricTile(Icons.bolt, 'Energy Output', '42.8 kWh', '+12%', AppTheme.primary),
              ],
            ),
            const SizedBox(height: 24),
            // Recommendations
            Text('AI Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 12),
            _recommendation(
              Icons.trending_up,
              'Increase feed rate by 5%',
              'Current substrate levels support higher input. Projected 8% increase in gas output.',
              AppTheme.primary,
            ),
            _recommendation(
              Icons.warning_amber,
              'Schedule maintenance for Sensor MQ-4',
              'Calibration drift detected. Recommended within 48 hours.',
              const Color(0xFFF57F17),
            ),
            _recommendation(
              Icons.eco,
              'Optimize agitation schedule',
              'Reducing agitation frequency by 15% could improve methane yield.',
              AppTheme.tertiary,
            ),
            const SizedBox(height: 16),
            // Report type selector
            Text('Report Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                _periodChip('Daily', false),
                const SizedBox(width: 8),
                _periodChip('Weekly', true),
                const SizedBox(width: 8),
                _periodChip('Monthly', false),
                const SizedBox(width: 8),
                _periodChip('Annual', false),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePdf,
                icon: _isGenerating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'Generating...' : 'Export PDF'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Export Excel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share Report'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _reportStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _metricTile(IconData icon, String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(change, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recommendation(IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductionChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = [0.5, 0.6, 0.55, 0.7, 0.65, 0.8, 0.75];

    // Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * (size.height - 20);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line chart
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.primary.withValues(alpha: 0.2), AppTheme.primary.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height - 20))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final chartHeight = size.height - 20;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = chartHeight - data[i] * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      // Dot
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppTheme.primary);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }

    fillPath.lineTo(size.width, chartHeight);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
