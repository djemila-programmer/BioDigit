import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../services/providers.dart';

class AnomalyDetection extends StatefulWidget {
  const AnomalyDetection({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<AnomalyDetection> createState() => _AnomalyDetectionState();
}

class _AnomalyDetectionState extends State<AnomalyDetection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProv = context.read<SensorProvider>();
      if (sensorProv.latestReading != null) {
        context.read<AnomalyProvider>().analyze(sensorProv.latestReading!);
      }
      context.read<AnomalyProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFrench = context.watch<LocaleProvider>().isFrench;
    final anomalyProvider = context.watch<AnomalyProvider>();
    final report = anomalyProvider.report;
    final healthScore = report?.healthScore ?? 0;
    final riskScore = report?.riskScore ?? 0;
    final confidence = report?.predictionConfidence ?? 0.0;
    final sensorAnomalies = report?.sensorAnomalies ?? 0;
    final recommendedActions = report?.recommendedActions ?? 0;
    final severityLabel = report?.severityLevel ?? (isFrench ? 'En attente' : 'Waiting');

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: cs.onSurface),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(isFrench ? 'Détection d\'anomalies' : 'Anomaly Detection', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero - Health Score
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: const Text('ANALYSE DU SYSTEME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 12),
                            const Text('Etat du systeme', style: TextStyle(fontSize: 16, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(
                              severityLabel,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: report != null ? healthScore / 100 : null,
                                strokeWidth: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$healthScore%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                                const Text('Sante', style: TextStyle(fontSize: 10, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report == null
                        ? (isFrench ? 'En attente de données capteur pour générer une analyse.' : 'Waiting for sensor data to generate analysis.')
                        : (isFrench ? 'Dernière analyse: ${_formatTime(report.timestamp)}' : 'Last analysis: ${_formatTime(report.timestamp)}'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Risk Score + Confidence cards
            Row(
              children: [
                Expanded(
                  child: _scoreCard(
                    isFrench ? 'Score de risque' : 'Risk Score',
                    '$riskScore%',
                    riskScore > 70 ? (isFrench ? 'Élevé' : 'High') : riskScore > 35 ? (isFrench ? 'Moyen' : 'Medium') : (isFrench ? 'Faible' : 'Low'),
                    Icons.shield,
                    riskScore > 70 ? AppTheme.error : riskScore > 35 ? const Color(0xFFF57F17) : const Color(0xFF1B5E20),
                    riskScore / 100,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _scoreCard(
                    isFrench ? 'Confiance de détection' : 'Detection Confidence',
                    '${confidence.toStringAsFixed(1)}%',
                    confidence > 90 ? (isFrench ? 'Élevée' : 'High') : (isFrench ? 'À vérifier' : 'To verify'),
                    Icons.auto_graph,
                    AppTheme.tertiary,
                    confidence / 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _scoreCard(
                    isFrench ? 'Anomalies capteurs' : 'Sensor Anomalies',
                    '$sensorAnomalies',
                    sensorAnomalies > 0 ? (isFrench ? 'Détectées' : 'Detected') : (isFrench ? 'Aucune' : 'None'),
                    Icons.sensors,
                    AppTheme.secondary,
                    (sensorAnomalies / 10).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _scoreCard(
                    isFrench ? 'Actions recommandées' : 'Recommended Actions',
                    '$recommendedActions',
                    recommendedActions > 0 ? (isFrench ? 'En attente' : 'Pending') : 'OK',
                    Icons.assignment,
                    const Color(0xFFF57F17),
                    (recommendedActions / 10).clamp(0.0, 1.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Real sensor anomaly results from the report
            Text('Resultats par capteur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            if (report != null) ...[
              ...report.sensorResults.map((result) => _sensorResultCard(context, result)),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text('Aucune donnee capteur disponible.', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              ),
            const SizedBox(height: 24),

            // Recommended actions from the analysis
            if (report != null && report.actions.isNotEmpty) ...[
              Text('Actions recommandees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(height: 12),
              ...report.actions.map((action) => _actionCard(context, action)),
              const SizedBox(height: 24),
            ],

            // Anomaly Journal - history of past detections
            Text('Journal des anomalies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildAnomalyJournal(context, anomalyProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyJournal(BuildContext context, AnomalyProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final history = provider.history;
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text('Aucune anomalie enregistree.', style: TextStyle(color: cs.onSurfaceVariant)),
        ),
      );
    }

    return Column(
      children: history.take(10).map((entry) {
        final severity = entry['severity_level']?.toString() ?? 'Inconnu';
        final healthScore = entry['health_score']?.toString() ?? '--';
        final anomalies = entry['sensor_anomalies']?.toString() ?? '0';
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

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
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
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  severity == 'Critique' ? Icons.error : severity == 'Eleve' ? Icons.warning : Icons.info,
                  color: severityColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Severite: $severity',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      '$dateStr - $anomalies anomalie(s) detectee(s)',
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sante: $healthScore%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: severityColor),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sensorResultCard(BuildContext context, dynamic result) {
    final cs = Theme.of(context).colorScheme;
    final sensorName = result.sensorName as String;
    final value = result.value as double;
    final unit = result.unit as String;
    final severity = result.severity as String;
    final status = result.status as String;
    final message = result.message as String;
    final sensorId = result.sensorId as String;

    Color severityColor;
    IconData severityIcon;
    switch (severity) {
      case 'critical':
        severityColor = AppTheme.error;
        severityIcon = Icons.error;
        break;
      case 'warning':
        severityColor = const Color(0xFFF57F17);
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = const Color(0xFF1B5E20);
        severityIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: severityColor, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(severityIcon, color: severityColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(sensorName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    const SizedBox(width: 6),
                    Text('($sensorId)', style: TextStyle(fontSize: 10, color: cs.outline)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(message, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${value.toStringAsFixed(1)}$unit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: severityColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: severityColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, dynamic action) {
    final cs = Theme.of(context).colorScheme;
    Color priorityColor;
    switch (action.priority) {
      case 'Haute':
        priorityColor = AppTheme.error;
        break;
      case 'Moyenne':
        priorityColor = const Color(0xFFF57F17);
        break;
      default:
        priorityColor = const Color(0xFF1B5E20);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.build, color: priorityColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(action.description, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(action.priority.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: priorityColor)),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(String label, String value, String subtitle, IconData icon, Color color, double progress) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );});
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${_formatTime(dt)}';
  }
}
