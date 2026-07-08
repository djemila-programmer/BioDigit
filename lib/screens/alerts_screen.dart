import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../routes.dart';
import '../services/providers.dart';
import '../services/alert_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'all'; // all, critical, warning, info

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alertProvider = context.watch<AlertProvider>();
    final counts = alertProvider.counts;

    final allActive = alertProvider.alerts.where((a) => !a.resolved).toList();
    final filtered = _filter == 'all'
        ? allActive
        : allActive.where((a) => a.severity == _filter).toList();

    final cs = Theme.of(context).colorScheme;
    final isFrench = context.watch<LocaleProvider>().isFrench;
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
        title: Text(isFrench ? 'Gestion des alertes' : 'Alert Management', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      bottomNavigationBar: widget.showBackButton ? null : const BottomNavBar(currentIndex: 2),
      body: RefreshIndicator(
        onRefresh: _refreshAlerts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Hero card - Critical issues
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBA1A1A), Color(0xFF93000A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'IMMEDIATE ACTION REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${counts['critical'] ?? 0} Critical Issues',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${allActive.length} active alerts detected in the last 24 hours',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statPill(
                        '${counts['warning'] ?? 0} Warnings',
                        Icons.warning_amber,
                      ),
                      const SizedBox(width: 8),
                      _statPill(
                        '${counts['info'] ?? 0} Info',
                        Icons.info_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip(
                  'All (${allActive.length})',
                  _filter == 'all',
                  () => setState(() => _filter = 'all'),
                ),
                _filterChip(
                  'Critical (${counts['critical'] ?? 0})',
                  _filter == 'critical',
                  () => setState(() => _filter = 'critical'),
                ),
                _filterChip(
                  'Warning (${counts['warning'] ?? 0})',
                  _filter == 'warning',
                  () => setState(() => _filter = 'warning'),
                ),
                _filterChip(
                  'Info (${counts['info'] ?? 0})',
                  _filter == 'info',
                  () => setState(() => _filter = 'info'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              'Active Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            if (alertProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No active alerts for this filter.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              )
            else
              ...filtered.map((a) => _AlertCard(alert: a)),

            const SizedBox(height: 24),

            // Location map placeholder
            Text(
              'Alert Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppTheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Farm Map View',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 40,
                    child: _mapMarker(AppTheme.error, 'North Sector'),
                  ),
                  Positioned(
                    right: 80,
                    top: 80,
                    child: _mapMarker(AppTheme.secondary, 'East Sector'),
                  ),
                  Positioned(
                    left: 120,
                    bottom: 40,
                    child: _mapMarker(AppTheme.outline, 'Main Grid'),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAlerts() async {
    context.read<AlertProvider>().startListening();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Widget _statPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
  String label,
  bool selected,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected
              ? AppTheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

  Widget _mapMarker(Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.warning, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SmartAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: alert.severityColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: alert.severityColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alert.severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(alert.icon, color: alert.severityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alert.timeAgo} · ${alert.sensorId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: alert.severityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  alert.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: alert.severityColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.description,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                alert.location,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.anomalyDetection,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: alert.severityColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Investigate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
