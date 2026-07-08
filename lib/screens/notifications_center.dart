import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationsCenter extends StatefulWidget {
  const NotificationsCenter({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<NotificationsCenter> createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter> {
  String _selectedTab = 'All';

  final List<_Notification> _notifications = [
    _Notification(
      icon: Icons.warning,
      title: 'Critical: Methane Leak Risk',
      subtitle: 'Tank A pressure anomaly detected',
      time: '2 min ago',
      type: 'critical',
      unread: true,
    ),
    _Notification(
      icon: Icons.thermostat,
      title: 'Temperature Warning',
      subtitle: 'East Sector approaching 42°C threshold',
      time: '15 min ago',
      type: 'warning',
      unread: true,
    ),
    _Notification(
      icon: Icons.sensors_off,
      title: 'Critical: Sensor Disconnected',
      subtitle: 'HC-SR04 slurry level sensor lost connectivity',
      time: '28 min ago',
      type: 'critical',
      unread: true,
    ),
    _Notification(
      icon: Icons.build,
      title: 'Maintenance: MQ-4 Calibration Due',
      subtitle: 'Methane sensor calibration drift detected',
      time: '45 min ago',
      type: 'warning',
      unread: true,
    ),
    _Notification(
      icon: Icons.speed,
      title: 'Warning: Pressure Threshold Exceeded',
      subtitle: 'Biodigester pressure above 1.5 bar - valve activated',
      time: '1 hour ago',
      type: 'warning',
      unread: false,
    ),
    _Notification(
      icon: Icons.check_circle,
      title: 'Sensor Calibration Complete',
      subtitle: 'DHT22 recalibrated successfully',
      time: '1 hour ago',
      type: 'info',
      unread: false,
    ),
    _Notification(
      icon: Icons.wifi,
      title: 'Sensor Status: ESP8266 Reconnected',
      subtitle: 'Wi-Fi connection restored after 3 min interruption',
      time: '2 hours ago',
      type: 'info',
      unread: false,
    ),
    _Notification(
      icon: Icons.bolt,
      title: 'Grid Export Successful',
      subtitle: '2.4 kWh exported to main grid',
      time: '2 hours ago',
      type: 'info',
      unread: false,
    ),
    _Notification(
      icon: Icons.update,
      title: 'System Update Available',
      subtitle: 'ESP8266 firmware v2.4.1 ready',
      time: '3 hours ago',
      type: 'info',
      unread: true,
    ),
    _Notification(
      icon: Icons.eco,
      title: 'Weekly Report Generated',
      subtitle: 'Biogas production up 8% this week',
      time: '5 hours ago',
      type: 'info',
      unread: false,
    ),
    _Notification(
      icon: Icons.security,
      title: 'Security Alert',
      subtitle: 'Nouvelle connexion depuis le bureau de Ouagadougou',
      time: '1 day ago',
      type: 'warning',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedTab == 'All'
        ? _notifications
        : _notifications.where((n) => n.type == _selectedTab.toLowerCase()).toList();

    final cs = Theme.of(context).colorScheme;
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
        title: Text('Notifications', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (final item in _notifications) {
                  item.unread = false;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
            child: const Text('Mark all read', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBackButton ? null : const BottomNavBar(currentIndex: 2),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', 'Critical', 'Warning', 'Info'].map((tab) {
                final selected = _selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      tab,
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
          ),
          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final notif = filtered[index];
                return _NotificationTile(notification: notif);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _Notification notification;
  const _NotificationTile({required this.notification});

  Color get _color {
    switch (notification.type) {
      case 'critical':
        return AppTheme.error;
      case 'warning':
        return const Color(0xFFF57F17);
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.unread ? _color.withValues(alpha: 0.04) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.unread ? _color.withValues(alpha: 0.2) : cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(notification.icon, size: 20, color: _color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (notification.unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  notification.subtitle,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.time,
                  style: TextStyle(fontSize: 11, color: cs.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notification {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String type;
  bool unread;

  _Notification({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.unread,
  });
}
