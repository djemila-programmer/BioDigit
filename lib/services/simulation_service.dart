import 'dart:async';
import 'dart:math';
import '../supabase.dart';
import 'sensor_service.dart';

/// Simulation engine that generates realistic biodigester sensor data.
///
/// This implements the "digital twin" approach for academic validation:
/// simulated values are built from documented operating ranges in scientific
/// literature on biodigesters to reproduce real operating conditions.
///
/// Operating ranges (literature-based):
/// - Temperature: 28°C – 40°C (mesophilic zone 30-38°C optimal)
/// - Pressure: 0.8 – 1.5 bar (normal), up to 5 bar critical
/// - Methane (CH4): 150 – 500 ppm (normal production range)
/// - Slurry level: 20% – 90% (operating window)
class SimulationService {
  Timer? _timer;
  bool _isRunning = false;

  final Random _rng = Random();
  int _tickCount = 0;

  // Baseline operating conditions
  double _baseTemp = 34.0;
  double _basePressure = 1.1;
  double _baseMethane = 320.0;
  double _baseLevel = 72.0;

  bool get isRunning => _isRunning;

  /// Start the simulation loop. Pushes a reading every [interval] seconds.
  void start({int intervalSeconds = 5}) {
    if (_isRunning) return;
    _isRunning = true;
    _tickCount = 0;
    print('[Simulation] Démarrage (intervalle: ${intervalSeconds}s)');

    _pushReading(); // immediate first reading
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      _pushReading();
    });
  }

  /// Stop the simulation loop.
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Generate a single simulated reading and push it to Supabase.
  Future<SensorReading> _pushReading() async {
    _tickCount++;
    final reading = _generateReading();

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return reading;

    try {
      await supabase.from('sensor_readings').insert({
        'user_id': uid,
        'temperature': reading.temperature,
        'pressure': reading.pressure,
        'methane': reading.methane,
        'slurry_level': reading.slurryLevel,
        'temperature_trend': reading.temperatureTrend,
        'pressure_trend': reading.pressureTrend,
        'methane_trend': reading.methaneTrend,
        'slurry_trend': reading.slurryTrend,
      });
      print('[Simulation] Lecture envoyée: ${reading.temperature}°C');
    } catch (e) {
      print('[Simulation] ERREUR: $e');
    }

    return reading;
  }

  /// Generate a realistic sensor reading with natural drift and occasional anomalies.
  SensorReading _generateReading() {
    final t = _tickCount.toDouble();

    // Natural drift: slow sinusoidal + small random noise
    final tempDrift = sin(t * 0.05) * 2.0 + _noise(0.3);
    final pressDrift = sin(t * 0.03 + 1.0) * 0.15 + _noise(0.02);
    final methaneDrift = sin(t * 0.04 + 2.0) * 30.0 + _noise(5.0);
    final levelDrift = sin(t * 0.02 + 3.0) * 5.0 + _noise(0.8);

    // Inject anomalies at specific intervals for demonstration
    double tempAnomaly = 0;
    double pressAnomaly = 0;
    double methaneAnomaly = 0;

    // Temperature spike every ~60 ticks (5 min at 5s interval)
    if (_tickCount % 60 >= 55 && _tickCount % 60 != 0) {
      tempAnomaly = 6.0 + _noise(1.0);
    }
    // Pressure spike every ~90 ticks
    if (_tickCount % 90 >= 85 && _tickCount % 90 != 0) {
      pressAnomaly = 0.6 + _noise(0.1);
    }
    // Methane drop every ~120 ticks
    if (_tickCount % 120 >= 115 && _tickCount % 120 != 0) {
      methaneAnomaly = -120.0 + _noise(10.0);
    }

    double temp = (_baseTemp + tempDrift + tempAnomaly).clamp(25.0, 45.0);
    double pressure = (_basePressure + pressDrift + pressAnomaly).clamp(0.5, 5.0);
    double methane = (_baseMethane + methaneDrift + methaneAnomaly).clamp(100.0, 600.0);
    double level = (_baseLevel + levelDrift).clamp(15.0, 95.0);

    // Slowly evolve baseline to simulate real-world variation
    _baseTemp += _noise(0.02);
    _baseTemp = _baseTemp.clamp(30.0, 38.0);
    _basePressure += _noise(0.005);
    _basePressure = _basePressure.clamp(0.9, 1.4);
    _baseMethane += _noise(0.5);
    _baseMethane = _baseMethane.clamp(250.0, 420.0);
    _baseLevel += _noise(0.1);
    _baseLevel = _baseLevel.clamp(50.0, 88.0);

    // Compute trends
    String tempTrend = tempDrift > 0.5 ? 'rising' : tempDrift < -0.5 ? 'falling' : 'stable';
    String pressTrend = pressDrift > 0.03 ? 'rising' : pressDrift < -0.03 ? 'falling' : 'stable';
    String methaneTrend = methaneDrift > 5.0 ? 'rising' : methaneDrift < -5.0 ? 'falling' : 'stable';
    String levelTrend = levelDrift > 1.0 ? 'rising' : levelDrift < -1.0 ? 'falling' : 'stable';

    return SensorReading(
      temperature: double.parse(temp.toStringAsFixed(1)),
      pressure: double.parse(pressure.toStringAsFixed(2)),
      methane: double.parse(methane.toStringAsFixed(0)),
      slurryLevel: double.parse(level.toStringAsFixed(1)),
      timestamp: DateTime.now(),
      temperatureTrend: tempTrend,
      pressureTrend: pressTrend,
      methaneTrend: methaneTrend,
      slurryTrend: levelTrend,
    );
  }

  double _noise(double amplitude) {
    return (_rng.nextDouble() * 2 - 1) * amplitude;
  }
}
