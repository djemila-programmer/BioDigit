import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../routes.dart';
import '../services/providers.dart';
import 'farm_management.dart';
import 'anomaly_detection.dart';
import 'settings_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  static const _navItems = [
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
    {'icon': Icons.people, 'label': 'Users'},
    {'icon': Icons.map, 'label': 'Farms'},
    {'icon': Icons.analytics, 'label': 'Analytics'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  Widget _getPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const _AdminHomeContent();
      case 1:
        return const _AdminUsersContent();
      case 2:
        return const FarmManagement();
      case 3:
        return const AnomalyDetection();
      case 4:
        return const SettingsScreen();
      default:
        return const _AdminHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            if (isMobile) {
              return Column(
                children: [
                  Expanded(child: _getPage(context, _currentIndex)),
                  _buildBottomNav(),
                ],
              );
            }
            final sidebarWidth = (constraints.maxWidth * 0.10).clamp(
              56.0,
              72.0,
            );
            return Row(
              children: [
                _buildSidebar(context, sidebarWidth),
                Expanded(child: _getPage(context, _currentIndex)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (i) {
            final active = _currentIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _navItems[i]['icon'] as IconData,
                        size: 22,
                        color: active
                            ? AppTheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _navItems[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? AppTheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, double sidebarWidth) {
    return SizedBox(
      width: sidebarWidth,
      child: Container(
        color: AppTheme.primary,
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.eco, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 32),
            ...List.generate(_navItems.length, (i) {
              final active = _currentIndex == i;
              return _sideIcon(
                _navItems[i]['icon'] as IconData,
                active,
                () => setState(() => _currentIndex = i),
              );
            }),
            const Spacer(),
            _sideIcon(Icons.logout, false, () {
              context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sideIcon(IconData icon, bool active, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Admin Home Content (the original dashboard) ───
class _AdminHomeContent extends StatelessWidget {
  const _AdminHomeContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 480;
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BioSmart Burkina Faso',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.notifications,
                          ),
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'BioSmart Burkina Faso · Réseau de Monitoring',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        ),
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryContainer.withValues(
                          alpha: 0.1,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Stats cards - responsive wrapping (real data)
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 480;

              final farmProvider = context.watch<FarmProvider>();
              final farmsCount = farmProvider.farms.length;

              final systemStats = farmProvider.systemStats;
              final totalEnergy =
                  (systemStats?['totalEnergyProduction'] as num?)?.toDouble() ??
                  0;

              // Keep UI stable with safe formatting
              final activeText = farmsCount.toString();
              final energyText = totalEnergy > 0
                  ? totalEnergy.toStringAsFixed(1)
                  : '0.0';

              if (narrow) {
                return Column(
                  children: [
                    _bigStatCard(
                      context,
                      activeText,
                      'Active Biodigesters',
                      Icons.storage,
                      AppTheme.primary,
                      '+ this week',
                    ),
                    const SizedBox(height: 12),
                    _bigStatCard(
                      context,
                      energyText,
                      'MWh Energy',
                      Icons.bolt,
                      AppTheme.secondary,
                      'Today',
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _bigStatCard(
                                context,
                      activeText,
                      'Active Biodigesters',
                      Icons.storage,
                      AppTheme.primary,
                      '+ this week',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _bigStatCard(
                                context,
                      energyText,
                      'MWh Energy',
                      Icons.bolt,
                      AppTheme.secondary,
                      'Today',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Alert density + performance
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 480;
              if (narrow) {
                return Column(
                  children: [
                    _alertDensityCard(context),
                    const SizedBox(height: 12),
                    _performanceCard(context),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _alertDensityCard(context)),
                  const SizedBox(width: 12),
                  Expanded(child: _performanceCard(context)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Farm Manager Directory
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farm Manager Directory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.farmManagement),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Manager',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Farm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...FarmManager.mockManagers.map((m) => _managerRow(context, m)),
          const SizedBox(height: 24),
          Text(
            'System Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 480;
              final cards1 = [
                _configCard(
                  Icons.tune,
                  'Threshold Config',
                  'Set safe ranges',
                  AppTheme.primary,
                  AppRoutes.thresholdManagement,
                ),
                _configCard(
                  Icons.people,
                  'User Management',
                  '5 admins',
                  AppTheme.tertiary,
                  '',
                ),
                _configCard(
                  Icons.sensors,
                  'Sensor Management',
                  '4 active',
                  AppTheme.secondary,
                  AppRoutes.sensorManagement,
                ),
              ];
              final cards2 = [
                _configCard(
                  Icons.notifications_active,
                  'Alert Management',
                  '7 active',
                  AppTheme.error,
                  AppRoutes.alerts,
                ),
                _configCard(
                  Icons.assignment,
                  'Report Generation',
                  'Auto-daily',
                  AppTheme.primary,
                  AppRoutes.reports,
                ),
                _configCard(
                  Icons.settings,
                  'System Config',
                  'v2.4.1-bf',
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  AppRoutes.settings,
                ),
              ];
              if (narrow) {
                return Column(
                  children: [
                    ...cards1.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: c,
                      ),
                    ),
                    ...cards2.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: c,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: cards1[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards1[1]),
                      const SizedBox(width: 12),
                      Expanded(child: cards1[2]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: cards2[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards2[1]),
                      const SizedBox(width: 12),
                      Expanded(child: cards2[2]),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bigStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertDensityCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert Density',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _heatBar(context, 0.3, AppTheme.primary, 'Mon'),
                _heatBar(context, 0.5, const Color(0xFFF57F17), 'Tue'),
                _heatBar(context, 0.8, AppTheme.error, 'Wed'),
                _heatBar(context, 0.4, const Color(0xFFF57F17), 'Thu'),
                _heatBar(context, 0.2, AppTheme.primary, 'Fri'),
                _heatBar(context, 0.6, const Color(0xFFF57F17), 'Sat'),
                _heatBar(context, 0.35, AppTheme.primary, 'Sun'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(context, AppTheme.primary, 'Normal'),
              const SizedBox(width: 12),
              _legendDot(context, const Color(0xFFF57F17), 'Warning'),
              const SizedBox(width: 12),
              _legendDot(context, AppTheme.error, 'Critical'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _perfMetric(context, 'Avg Methane', '64.2%', 0.64, AppTheme.primary),
          const SizedBox(height: 10),
          _perfMetric(context, 'System Pressure', '2.4 bar', 0.6, AppTheme.tertiary),
          const SizedBox(height: 10),
          _perfMetric(context, 'Digester Temp', '37.5°C', 0.75, AppTheme.secondary),
          const SizedBox(height: 10),
          _perfMetric(context, 'pH Level', '7.1', 0.71, const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  Widget _heatBar(BuildContext context, double height, Color color, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: FractionallySizedBox(
                heightFactor: height,
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _perfMetric(BuildContext context, String label, String value, double progress, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _managerRow(BuildContext context, FarmManager manager) {
    final cs = Theme.of(context).colorScheme;
    Color statusColor;
    switch (manager.status) {
      case 'Healthy':
        statusColor = const Color(0xFF1B5E20);
        break;
      case 'Maintenance':
        statusColor = const Color(0xFFF57F17);
        break;
      default:
        statusColor = AppTheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryContainer.withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    manager.initials,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manager.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        manager.email,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              manager.assignedFarm,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                manager.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _configCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
  ) {
    return Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return InkWell(
        onTap: () {
          if (route.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title is coming soon.')),
            );
            return;
          }
          Navigator.pushNamed(context, route);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}

// ─── Admin Users Content ───
class _AdminUsersContent extends StatelessWidget {
  const _AdminUsersContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final users = [
      {
        'name': 'Djemila Bonkoungou',
        'email': 'admin@biodigit.bf',
        'role': 'Admin',
        'status': 'Active',
      },
      {
        'name': 'Amadou Ouédraogo',
        'email': 'amadou@biodigit.bf',
        'role': 'Manager',
        'status': 'Active',
      },
      {
        'name': 'Ibrahim Sawadogo',
        'email': 'i.sawadogo@biodigit.bf',
        'role': 'Manager',
        'status': 'Active',
      },
      {
        'name': 'Fatimata Kaboré',
        'email': 'f.kabore@biodigit.bf',
        'role': 'Viewer',
        'status': 'Inactive',
      },
      {
        'name': 'Moussa Traoré',
        'email': 'm.traore@biodigit.bf',
        'role': 'Manager',
        'status': 'Active',
      },
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${users.length} registered users',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...users.map((u) {
            final isActive = u['status'] == 'Active';
            final statusColor = isActive
                ? const Color(0xFF1B5E20)
                : cs.outlineVariant;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u['name']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          u['email']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      u['role']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u['status']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
