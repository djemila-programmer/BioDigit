import 'package:flutter/material.dart';

IconData trendIcon(String trend) {
  switch (trend) {
    case 'rising':
      return Icons.trending_up;
    case 'falling':
      return Icons.trending_down;
    default:
      return Icons.trending_flat;
  }
}
