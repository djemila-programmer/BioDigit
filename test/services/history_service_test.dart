import 'package:biodigit_app/services/history_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryService demo mode', () {
    final service = HistoryService();

    Future<void> expectDemoSeries(
      Future<List<HistoryPoint>> Function() fetcher,
      int expectedLength,
    ) async {
      final points = await fetcher();
      expect(points, hasLength(expectedLength));
      for (final point in points) {
        expect(point.temperature, greaterThan(0));
        expect(point.pressure, greaterThan(0));
        expect(point.methane, greaterThan(0));
        expect(point.slurryLevel, greaterThan(0));
      }
      for (var i = 1; i < points.length; i++) {
        expect(points[i - 1].timestamp.isBefore(points[i].timestamp), isTrue);
      }
    }

    test('returns 24 hourly demo points', () async {
      await expectDemoSeries(service.getLast24Hours, 24);
    });

    test('returns 7 daily demo points', () async {
      await expectDemoSeries(service.getLast7Days, 7);
    });

    test('returns 30 daily demo points', () async {
      await expectDemoSeries(service.getLast30Days, 30);
    });

    test('returns 12 monthly demo points', () async {
      await expectDemoSeries(service.getLast12Months, 12);
    });

    test('production summary echoes period and demo values', () async {
      final weekly = await service.getProductionSummary('weekly');
      final quarterly = await service.getProductionSummary('quarterly');

      expect(weekly.volume, 87.5);
      expect(weekly.efficiency, 78.2);
      expect(weekly.readingCount, 168);
      expect(weekly.period, 'weekly');

      expect(quarterly.period, 'quarterly');
      expect(quarterly.volume, 87.5);
      expect(quarterly.efficiency, 78.2);
      expect(quarterly.readingCount, 168);
    });

    test('production summary empty has zero values', () {
      final summary = ProductionSummary.empty();

      expect(summary.volume, 0.0);
      expect(summary.efficiency, 0.0);
      expect(summary.energyGenerated, 0.0);
      expect(summary.co2Reduction, 0.0);
      expect(summary.readingCount, 0);
      expect(summary.period, 'daily');
    });
  });
}
