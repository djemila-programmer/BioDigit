import 'package:biodigit_app/models/alert_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertModel', () {
    test('severity colors map to the expected values', () {
      expect(
        AlertModel(
          id: '1',
          title: 't',
          description: 'd',
          severity: 'critical',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.warning,
        ).severityColor,
        const Color(0xFFBA1A1A),
      );

      expect(
        AlertModel(
          id: '2',
          title: 't',
          description: 'd',
          severity: 'warning',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.warning,
        ).severityColor,
        const Color(0xFF7A5649),
      );

      expect(
        AlertModel(
          id: '3',
          title: 't',
          description: 'd',
          severity: 'info',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.info,
        ).severityColor,
        const Color(0xFF717A6D),
      );

      expect(
        AlertModel(
          id: '4',
          title: 't',
          description: 'd',
          severity: 'anything',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.info,
        ).severityColor,
        const Color(0xFF717A6D),
      );
    });

    test('severity container colors map to the expected values', () {
      expect(
        AlertModel(
          id: '1',
          title: 't',
          description: 'd',
          severity: 'critical',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.warning,
        ).severityContainerColor,
        const Color(0xFFFFDAD6),
      );

      expect(
        AlertModel(
          id: '2',
          title: 't',
          description: 'd',
          severity: 'warning',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.warning,
        ).severityContainerColor,
        const Color(0xFFFDCDBC),
      );

      expect(
        AlertModel(
          id: '3',
          title: 't',
          description: 'd',
          severity: 'info',
          timeAgo: 'now',
          location: 'loc',
          sensorId: 's',
          icon: Icons.info,
        ).severityContainerColor,
        const Color(0xFFE2E2E2),
      );
    });

    test('mock alerts are non-empty and have ids', () {
      expect(AlertModel.mockAlerts, isNotEmpty);
      for (final alert in AlertModel.mockAlerts) {
        expect(alert.id, isNotEmpty);
      }
    });
  });
}
