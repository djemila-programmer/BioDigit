import '../supabase.dart';

/// Supabase-based farm management service with full CRUD operations.
class FarmService {
  String? get _uid => supabase.auth.currentUser?.id;

  // ─── Farm CRUD ──────────────────────────────────────────────────────────

  Future<String> createFarm({
    required String name,
    required String location,
    required String biodigesterType,
    required double biodigesterCapacity,
    int cows = 0,
    int pigs = 0,
    int goats = 0,
    int poultry = 0,
    double wasteProduction = 0,
    double energyProduction = 0,
  }) async {
    if (_uid == null) throw Exception('Non connecté.');
    final response = await supabase.from('farms').insert({
      'user_id': _uid,
      'name': name,
      'location': location,
      'biodigester_type': biodigesterType,
      'biodigester_capacity': biodigesterCapacity,
      'cows': cows,
      'pigs': pigs,
      'goats': goats,
      'poultry': poultry,
      'waste_production': wasteProduction,
      'energy_production': energyProduction,
      'status': 'active',
    }).select('id').single();
    return response['id'] as String;
  }

  Future<List<FarmData>> getUserFarms() async {
    if (_uid == null) return [];
    final response = await supabase
        .from('farms')
        .select()
        .eq('user_id', _uid!);
    return (response as List).map((row) => FarmData.fromSupabase(row as Map<String, dynamic>)).toList();
  }

  Future<FarmData?> getFarm(String farmId) async {
    final response = await supabase
        .from('farms')
        .select()
        .eq('id', farmId)
        .maybeSingle();
    if (response == null) return null;
    return FarmData.fromSupabase(response);
  }

  Future<void> updateFarm(String farmId, Map<String, dynamic> updates) async {
    await supabase.from('farms').update(updates).eq('id', farmId);
  }

  Future<void> deleteFarm(String farmId) async {
    await supabase.from('farms').delete().eq('id', farmId);
  }

  // ─── Feeding Schedule ───────────────────────────────────────────────────

  Future<List<FeedingEntry>> getFeedingSchedule(String farmId) async {
    final response = await supabase
        .from('feedings')
        .select()
        .eq('farm_id', farmId)
        .order('time');
    return response.map((row) => FeedingEntry.fromSupabase(row)).toList();
  }

  Future<void> addFeedingEntry(String farmId, {
    required String time,
    required String type,
    required double amount,
    required String status,
  }) async {
    await supabase.from('feedings').insert({
      'farm_id': farmId,
      'time': time,
      'type': type,
      'amount': amount,
      'status': status,
    });
  }

  Future<void> updateFeedingStatus(String farmId, String entryId, String status) async {
    await supabase.from('feedings').update({'status': status}).eq('id', entryId);
  }

  // ─── Admin: All Farms ───────────────────────────────────────────────────

  Future<List<FarmData>> getAllFarms() async {
    final response = await supabase.rpc('get_all_farms');
    return (response as List).map((row) => FarmData.fromSupabase(row as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getSystemStats() async {
    final farmsResponse = await supabase.rpc('get_all_farms');
    final usersResponse = await supabase.rpc('get_all_profiles');
    final alertsResponse = await supabase.rpc('get_all_alerts').eq('resolved', false);

    int totalCows = 0, totalPigs = 0;
    double totalEnergy = 0, totalWaste = 0;
    for (final doc in farmsResponse) {
      totalCows += (doc['cows'] as num?)?.toInt() ?? 0;
      totalPigs += (doc['pigs'] as num?)?.toInt() ?? 0;
      totalEnergy += (doc['energy_production'] as num?)?.toDouble() ?? 0;
      totalWaste += (doc['waste_production'] as num?)?.toDouble() ?? 0;
    }
    return {
      'totalFarms': farmsResponse.length,
      'totalUsers': usersResponse.length,
      'activeAlerts': alertsResponse.length,
      'totalCows': totalCows,
      'totalPigs': totalPigs,
      'totalEnergyProduction': totalEnergy,
      'totalWasteProcessed': totalWaste,
    };
  }
}

// ─── Data Classes ──────────────────────────────────────────────────────────

class FarmData {
  final String id;
  final String ownerId;
  final String name;
  final String location;
  final String biodigesterType;
  final double biodigesterCapacity;
  final int cows;
  final int pigs;
  final int goats;
  final int poultry;
  final double wasteProduction;
  final double energyProduction;
  final String status;
  final DateTime? createdAt;

  const FarmData({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.location,
    required this.biodigesterType,
    required this.biodigesterCapacity,
    this.cows = 0,
    this.pigs = 0,
    this.goats = 0,
    this.poultry = 0,
    this.wasteProduction = 0,
    this.energyProduction = 0,
    this.status = 'active',
    this.createdAt,
  });

  factory FarmData.fromSupabase(Map<String, dynamic> data) {
    return FarmData(
      id: data['id']?.toString() ?? '',
      ownerId: data['user_id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      biodigesterType: data['biodigester_type']?.toString() ?? '',
      biodigesterCapacity: (data['biodigester_capacity'] as num?)?.toDouble() ?? 0,
      cows: (data['cows'] as num?)?.toInt() ?? 0,
      pigs: (data['pigs'] as num?)?.toInt() ?? 0,
      goats: (data['goats'] as num?)?.toInt() ?? 0,
      poultry: (data['poultry'] as num?)?.toInt() ?? 0,
      wasteProduction: (data['waste_production'] as num?)?.toDouble() ?? 0,
      energyProduction: (data['energy_production'] as num?)?.toDouble() ?? 0,
      status: data['status']?.toString() ?? 'active',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': ownerId,
        'name': name,
        'location': location,
        'biodigester_type': biodigesterType,
        'biodigester_capacity': biodigesterCapacity,
        'cows': cows,
        'pigs': pigs,
        'goats': goats,
        'poultry': poultry,
        'waste_production': wasteProduction,
        'energy_production': energyProduction,
        'status': status,
      };
}

class FeedingEntry {
  final String id;
  final String time;
  final String type;
  final double amount;
  final String status;

  const FeedingEntry({
    required this.id,
    required this.time,
    required this.type,
    required this.amount,
    required this.status,
  });

  factory FeedingEntry.fromSupabase(Map<String, dynamic> data) {
    return FeedingEntry(
      id: data['id']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: data['status']?.toString() ?? 'pending',
    );
  }
}
