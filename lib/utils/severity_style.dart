import 'package:flutter/material.dart';

/// Maps an alert severity ('critical' | 'warning' | other) to display styles.
Color severityColor(String severity) {
  switch (severity) {
    case 'critical':
      return const Color(0xFFBA1A1A);
    case 'warning':
      return const Color(0xFF7A5649);
    default:
      return const Color(0xFF717A6D);
  }
}

Color severityContainerColor(String severity) {
  switch (severity) {
    case 'critical':
      return const Color(0xFFFFDAD6);
    case 'warning':
      return const Color(0xFFFDCDBC);
    default:
      return const Color(0xFFE2E2E2);
  }
}

IconData severityIcon(String severity) {
  switch (severity) {
    case 'critical':
      return Icons.error;
    case 'warning':
      return Icons.warning;
    default:
      return Icons.info;
  }
}
