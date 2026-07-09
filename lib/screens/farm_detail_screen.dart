import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../supabase.dart';
import '../theme/app_theme.dart';
import '../services/providers.dart';

class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({super.key});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  Map<String, dynamic>? _farm;
  Map<String, dynamic>? _owner;
  Map<String, dynamic>? _latestReading;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFarmData());
  }

  Future<void> _loadFarmData() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final farmId = args?['farmId'] as String?;
    
    print('FarmDetail: farmId=$farmId, args=$args');
    
    if (farmId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Load all farms via RPC and filter locally
      final allFarms = await supabase.rpc('get_all_farms');
      print('FarmDetail: RPC returned ${(allFarms as List).length} farms');
      
      final farmResponse = (allFarms as List)
          .map((f) => f as Map<String, dynamic>)
          .firstWhere(
            (f) => f['id']?.toString() == farmId,
            orElse: () => <String, dynamic>{},
          );
      
      print('FarmDetail: farm found: ${farmResponse.isNotEmpty}');
      if (farmResponse.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      
      final userId = farmResponse['user_id']?.toString();
      print('FarmDetail: userId=$userId');

      // Load latest sensor reading
      Map<String, dynamic>? reading;
      if (userId != null) {
        try {
          final readings = await supabase
              .from('sensor_readings')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(1);
          if (readings.isNotEmpty) {
            reading = readings.first as Map<String, dynamic>;
          }
        } catch (e) {
          print('FarmDetail: sensor_readings error=$e');
        }
      }

      // Load owner profile via RPC
      Map<String, dynamic>? owner;
      if (userId != null) {
        try {
          final allProfiles = await supabase.rpc('get_all_profiles');
          final profiles = allProfiles as List;
          print('FarmDetail: profiles count=${profiles.length}');
          final matchProfile = profiles
              .map((p) => p as Map<String, dynamic>)
              .where((p) => p['id']?.toString() == userId)
              .toList();
          if (matchProfile.isNotEmpty) {
            owner = matchProfile.first;
          }
          print('FarmDetail: owner found: ${owner != null}');
        } catch (e) {
          print('FarmDetail: profiles error=$e');
        }
      }

      if (mounted) {
        setState(() {
          _farm = farmResponse;
          _owner = owner;
          _latestReading = reading;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('FarmDetail: ERROR=$e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFrench = context.watch<LocaleProvider>().isFrench;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFrench ? 'Détails de la ferme' : 'Farm Details',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _farm == null
              ? Center(
                  child: Text(
                    isFrench ? 'Ferme non trouvée' : 'Farm not found',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farm header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _farm?['name'] ?? 'Ferme',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _farm?['location'] ?? '',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                _farm?['status'] ?? 'active',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Owner info
                      _sectionTitle(isFrench ? 'Propriétaire' : 'Owner'),
                      const SizedBox(height: 12),
                      _infoCard([
                        _infoRow(Icons.person, isFrench ? 'Nom' : 'Name', _owner?['full_name'] ?? ''),
                        _infoRow(Icons.email, 'Email', _owner?['email'] ?? ''),
                      ]),
                      const SizedBox(height: 24),

                      // Biodigester info
                      _sectionTitle(isFrench ? 'Biodigesteur' : 'Biodigester'),
                      const SizedBox(height: 12),
                      _infoCard([
                        _infoRow(Icons.category, isFrench ? 'Type' : 'Type', _farm?['biodigester_type'] ?? ''),
                        _infoRow(Icons.straighten, isFrench ? 'Capacité' : 'Capacity', '${_farm?['biodigester_capacity'] ?? 0} m³'),
                        _infoRow(Icons.pets, isFrench ? 'Bovins' : 'Cows', '${_farm?['cows'] ?? 0}'),
                        _infoRow(Icons.grid_view, isFrench ? 'Porcins' : 'Pigs', '${_farm?['pigs'] ?? 0}'),
                      ]),
                      const SizedBox(height: 24),

                      // Sensor readings
                      _sectionTitle(isFrench ? 'Lectures capteurs' : 'Sensor Readings'),
                      const SizedBox(height: 12),
                      if (_latestReading != null) ...[
                        _sensorCard(
                          Icons.thermostat,
                          isFrench ? 'Température' : 'Temperature',
                          '${(_latestReading!['temperature'] as num?)?.toStringAsFixed(1) ?? '--'}°C',
                          AppTheme.primary,
                        ),
                        const SizedBox(height: 8),
                        _sensorCard(
                          Icons.speed,
                          isFrench ? 'Pression' : 'Pressure',
                          '${(_latestReading!['pressure'] as num?)?.toStringAsFixed(2) ?? '--'} bar',
                          AppTheme.tertiary,
                        ),
                        const SizedBox(height: 8),
                        _sensorCard(
                          Icons.gas_meter,
                          isFrench ? 'Méthane' : 'Methane',
                          '${(_latestReading!['methane'] as num?)?.toStringAsFixed(0) ?? '--'} ppm',
                          AppTheme.primaryContainer,
                        ),
                        const SizedBox(height: 8),
                        _sensorCard(
                          Icons.inventory_2,
                          isFrench ? 'Niveau' : 'Level',
                          '${(_latestReading!['slurry_level'] as num?)?.toStringAsFixed(1) ?? '--'}%',
                          AppTheme.secondary,
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              isFrench ? 'Aucune donnée disponible' : 'No data available',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Production stats
                      _sectionTitle(isFrench ? 'Production' : 'Production'),
                      const SizedBox(height: 12),
                      _infoCard([
                        _infoRow(Icons.energy_savings_leaf, isFrench ? 'Énergie' : 'Energy', '${_farm?['energy_production'] ?? 0} MWh'),
                        _infoRow(Icons.recycling, isFrench ? 'Déchets' : 'Waste', '${_farm?['waste_production'] ?? 0} kg'),
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
