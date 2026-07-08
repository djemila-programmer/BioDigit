import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/biodigester_model.dart';

class FarmManagement extends StatelessWidget {
  const FarmManagement({super.key, this.showBackButton = false});

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
        title: Text('Farm Management', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      bottomNavigationBar: showBackButton ? null : const BottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ferme BioDigit Plateau Central', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('Plateau Central, Burkina Faso · Opérationnel', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryFixed.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryFixed)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _heroStat('124', 'Cows', Icons.pets),
                      _heroStat('86', 'Pigs', Icons.grid_view),
                      _heroStat('24°C', 'Temp', Icons.thermostat),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Livestock Inventory
            Text('Livestock Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _livestockCard(context, Icons.pets, 'Cattle', '124', '+3 this week', AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _livestockCard(context, Icons.grid_view, 'Swine', '86', '+5 this week', AppTheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Daily Input
            Text('Daily Input & Energy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                // Input donut
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text('Daily Input', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: 0.75,
                                  strokeWidth: 10,
                                  backgroundColor: cs.surfaceContainerHigh,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('750', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
                                  Text('kg', style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('of 1,000 kg target', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Energy metrics
                Expanded(
                  child: Column(
                    children: [
                      _energyCard(context, Icons.bolt, 'Biogas Potential', '8.4 m³', AppTheme.primary),
                      const SizedBox(height: 12),
                      _energyCard(context, Icons.electric_meter, 'Current Usage', '3.2 m³', AppTheme.secondary),
                      const SizedBox(height: 12),
                      _energyCard(context, Icons.eco, 'Eco Savings', '\$42.50', AppTheme.tertiary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Satellite Map placeholder
            Text('Farm Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.satellite_alt, size: 40, color: cs.outlineVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text('Satellite View', style: TextStyle(fontSize: 14, color: cs.outlineVariant)),
                    Text('Tap to expand', style: TextStyle(fontSize: 12, color: cs.outlineVariant.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionButton(Icons.add_circle_outline, 'Add Livestock', AppTheme.primary),
                const SizedBox(width: 12),
                _actionButton(Icons.assignment, 'Log Activity', AppTheme.secondary),
                const SizedBox(width: 12),
                _actionButton(Icons.bar_chart, 'View Reports', AppTheme.tertiary),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Farm Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    'Consignez les changements d’alimentation, de production et de maintenance pour garder un historique d’exploitation exploitable.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: cs.onSurfaceVariant.withValues(alpha: 0.95)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Biodigester Feeding Schedule
            Text('Biodigester Feeding Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            ...FeedingSchedule.mockSchedule.map((schedule) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: schedule.status == 'completed' ? const Color(0xFFE8F5E9) :
                              schedule.status == 'in_progress' ? const Color(0xFFFFF8E1) :
                              cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(schedule.time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: schedule.status == 'completed' ? const Color(0xFF1B5E20) : cs.onSurface)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(schedule.type, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
                        Text('${schedule.amount} kg', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: schedule.status == 'completed' ? const Color(0xFFE8F5E9) :
                              schedule.status == 'in_progress' ? const Color(0xFFFFF8E1) :
                              cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      schedule.status == 'completed' ? 'DONE' :
                      schedule.status == 'in_progress' ? 'IN PROGRESS' : 'PENDING',
                      style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold,
                        color: schedule.status == 'completed' ? const Color(0xFF1B5E20) :
                               schedule.status == 'in_progress' ? const Color(0xFFF57F17) :
                               cs.outlineVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // Organic Waste Tracking
            Text('Organic Waste Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _wasteRow(context, 'Bouse de vache', '450 kg', '60%', AppTheme.primary),
                  const SizedBox(height: 12),
                  _wasteRow(context, 'Lisier de porc', '200 kg', '27%', AppTheme.secondary),
                  const SizedBox(height: 12),
                  _wasteRow(context, 'Déchets organiques', '100 kg', '13%', AppTheme.tertiary),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Daily Input', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface)),
                        Text('750 kg / 1,000 kg', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      ],
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

  Widget _heroStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _livestockCard(BuildContext context, IconData icon, String title, String count, String change, Color color) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                child: Text(change, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _energyCard(BuildContext context, IconData icon, String label, String value, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _wasteRow(BuildContext context, String type, String amount, String percent, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(type, style: TextStyle(fontSize: 12, color: cs.onSurface)),
            Text('$amount ($percent)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: double.parse(percent.replaceAll('%', '')) / 100,
            minHeight: 4,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
