import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../models/biodigester_model.dart';

class ThresholdManagement extends StatefulWidget {
  const ThresholdManagement({super.key});

  @override
  State<ThresholdManagement> createState() => _ThresholdManagementState();
}

class _ThresholdManagementState extends State<ThresholdManagement> {
  late List<ThresholdConfig> _thresholds;

  @override
  void initState() {
    super.initState();
    _thresholds = List.from(ThresholdConfig.mockThresholds);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const AppHeader(title: 'Threshold Configuration', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.tertiary, AppTheme.tertiaryContainer],
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
                      'ADMINISTRATOR SETTINGS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Threshold Configuration',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set safe operating ranges for the biodigester system',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _heroStat(Icons.tune, '4 Parameters'),
                      const SizedBox(width: 16),
                      _heroStat(Icons.shield, 'Auto Protection'),
                      const SizedBox(width: 16),
                      _heroStat(Icons.notifications_active, 'Smart Alerts'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Threshold cards
            Text(
              'Operating Ranges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)
            ),
            const SizedBox(height: 12),

            ..._thresholds.asMap().entries.map((entry) {
              final index = entry.key;
              final threshold = entry.value;
              return _buildThresholdCard(context, index, threshold);
            }),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thresholds saved successfully'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Save All Thresholds'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _thresholds = List.from(ThresholdConfig.mockThresholds);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thresholds restored to defaults'),
                    ),
                  );
                },
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildThresholdCard(BuildContext context, int index, ThresholdConfig threshold) {
    final cs = Theme.of(context).colorScheme;
    final isWithinRange = threshold.currentValue >= threshold.minValue &&
        threshold.currentValue <= threshold.maxValue;
    final rangeSpan = threshold.maxValue - threshold.minValue;
    final rangePercent = rangeSpan == 0
      ? 0.0
      : (threshold.currentValue - threshold.minValue) / rangeSpan;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isWithinRange ? AppTheme.primary : AppTheme.error,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: threshold.color.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: threshold.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(threshold.icon, color: threshold.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threshold.label,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      'Current: ${threshold.currentValue} ${threshold.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isWithinRange ? AppTheme.primary : AppTheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isWithinRange ? const Color(0xFFE8F5E9) : const Color(0xFFFFDAD6),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  isWithinRange ? 'SAFE' : 'ALERT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isWithinRange ? const Color(0xFF1B5E20) : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Range bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: rangePercent.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWithinRange ? AppTheme.primary : AppTheme.error,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Min/Max sliders
          Row(
            children: [
              _rangeValue(context, 'Min', threshold.minValue, threshold.unit, threshold.color),
              const Spacer(),
              _rangeValue(context, 'Max', threshold.maxValue, threshold.unit, threshold.color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangeValue(BuildContext context, String label, double value, String unit, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.outline, letterSpacing: 0.5)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(width: 2),
            Text(unit, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
