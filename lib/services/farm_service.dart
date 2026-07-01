import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service_mixin.dart';

/// Firestore-based farm management service with full CRUD operations.
class FarmService with FirebaseServiceMixin {
  FirebaseFirestore? get _fs => firestoreOrNull;

  FirebaseAuth? get _authInst => authOrNull;

  String? get _uid =>
      _authInst?.currentUser?.uid ?? (authOrNull == null ? 'demo-user' : null);

  // ─── Farm CRUD ──────────────────────────────────────────────────────────

  Future<String> createFarm({
    required String name, required String location,
    required String biodigesterType, required double biodigesterCapacity,
    int cows = 0, int pigs = 0, int goats = 0, int poultry = 0,
    double wasteProduction = 0, double energyProduction = 0,
  }) async {
    if (_uid == null) throw Exception('Non connecté.');
    if (_fs == null) return 'demo-farm-id';
    final docRef = await _fs!.collection('farms').add({
      'ownerId': _uid, 'name': name, 'location': location,
      'biodigesterType': biodigesterType, 'biodigesterCapacity': biodigesterCapacity,
      'cows': cows, 'pigs': pigs, 'goats': goats, 'poultry': poultry,
      'wasteProduction': wasteProduction, 'energyProduction': energyProduction,
      'status': 'active', 'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<FarmData>> getUserFarms() async {
    if (_uid == null) return _demoFarms();
    if (_fs == null) return _demoFarms();
    final snapshot = await _fs!.collection('farms').where('ownerId', isEqualTo: _uid).get();
    return snapshot.docs.map((doc) => FarmData.fromFirestore(doc)).toList();
  }

  Future<FarmData?> getFarm(String farmId) async {
    if (_fs == null) return _demoFarms().first;
    final doc = await _fs!.collection('farms').doc(farmId).get();
    if (!doc.exists) return null;
    return FarmData.fromFirestore(doc);
  }

  Future<void> updateFarm(String farmId, Map<String, dynamic> updates) async {
    if (_fs == null) return;
    await _fs!.collection('farms').doc(farmId).update(updates);
  }

  Future<void> deleteFarm(String farmId) async {
    if (_fs == null) return;
    await _fs!.collection('farms').doc(farmId).delete();
  }

  // ─── Feeding Schedule ───────────────────────────────────────────────────

  Future<List<FeedingEntry>> getFeedingSchedule(String farmId) async {
    if (_fs == null) return [];
    final snapshot = await _fs!.collection('farms').doc(farmId).collection('feedings').orderBy('time').get();
    return snapshot.docs.map((doc) => FeedingEntry.fromFirestore(doc)).toList();
  }

  Future<void> addFeedingEntry(String farmId, {
    required String time, required String type,
    required double amount, required String status,
  }) async {
    if (_fs == null) return;
    await _fs!.collection('farms').doc(farmId).collection('feedings').add({
      'time': time, 'type': type, 'amount': amount, 'status': status,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFeedingStatus(String farmId, String entryId, String status) async {
    if (_fs == null) return;
    await _fs!.collection('farms').doc(farmId).collection('feedings').doc(entryId).update({'status': status});
  }

  // ─── Admin: All Farms ───────────────────────────────────────────────────

  Future<List<FarmData>> getAllFarms() async {
    if (_fs == null) return _demoFarms();
    final snapshot = await _fs!.collection('farms').get();
    return snapshot.docs.map((doc) => FarmData.fromFirestore(doc)).toList();
  }

  Future<Map<String, dynamic>> getSystemStats() async {
    if (_fs == null) {
      return {
        'totalFarms': 3, 'totalUsers': 12, 'activeAlerts': 7,
        'totalCows': 45, 'totalPigs': 28,
        'totalEnergyProduction': 256.8, 'totalWasteProcessed': 1240.0,
      };
    }
    final farmsSnapshot = await _fs!.collection('farms').get();
    final usersSnapshot = await _fs!.collection('users').get();
    final alertsSnapshot = await _fs!.collection('alerts').where('resolved', isEqualTo: false).get();
    int totalCows = 0, totalPigs = 0;
    double totalEnergy = 0, totalWaste = 0;
    for (final doc in farmsSnapshot.docs) {
      totalCows += (doc['cows'] as num?)?.toInt() ?? 0;
      totalPigs += (doc['pigs'] as num?)?.toInt() ?? 0;
      totalEnergy += (doc['energyProduction'] as num?)?.toDouble() ?? 0;
      totalWaste += (doc['wasteProduction'] as num?)?.toDouble() ?? 0;
    }
    return {
      'totalFarms': farmsSnapshot.size, 'totalUsers': usersSnapshot.size,
      'activeAlerts': alertsSnapshot.size, 'totalCows': totalCows,
      'totalPigs': totalPigs, 'totalEnergyProduction': totalEnergy,
      'totalWasteProcessed': totalWaste,
    };
  }

  List<FarmData> _demoFarms() => [
    FarmData(id: 'f1', ownerId: 'demo-user', name: 'Ferme BioSmart Ouaga', location: 'Plateau Central, Burkina Faso',
      biodigesterType: 'Fixed-dome', biodigesterCapacity: 15, cows: 20, pigs: 12, goats: 8, poultry: 50,
      wasteProduction: 450, energyProduction: 87.5, status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 90))),
    FarmData(id: 'f2', ownerId: 'demo-user', name: 'Coopérative Koudougou', location: 'Centre-Ouest, Burkina Faso',
      biodigesterType: 'Floating-drum', biodigesterCapacity: 25, cows: 35, pigs: 20, goats: 15, poultry: 80,
      wasteProduction: 680, energyProduction: 142.3, status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 60))),
    FarmData(id: 'f3', ownerId: 'demo-user', name: 'Ferme Pilote Bobo', location: 'Hauts-Bassins, Burkina Faso',
      biodigesterType: 'Fixed-dome', biodigesterCapacity: 10, cows: 10, pigs: 8, goats: 5, poultry: 30,
      wasteProduction: 220, energyProduction: 45.0, status: 'active', createdAt: DateTime.now().subtract(const Duration(days: 30))),
  ];
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

  factory FarmData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? created;
    final rawTs = data['createdAt'];
    if (rawTs is Timestamp) created = rawTs.toDate();

    return FarmData(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      biodigesterType: data['biodigesterType'] ?? '',
      biodigesterCapacity: (data['biodigesterCapacity'] as num?)?.toDouble() ?? 0,
      cows: (data['cows'] as num?)?.toInt() ?? 0,
      pigs: (data['pigs'] as num?)?.toInt() ?? 0,
      goats: (data['goats'] as num?)?.toInt() ?? 0,
      poultry: (data['poultry'] as num?)?.toInt() ?? 0,
      wasteProduction: (data['wasteProduction'] as num?)?.toDouble() ?? 0,
      energyProduction: (data['energyProduction'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'active',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
    'ownerId': ownerId,
    'name': name,
    'location': location,
    'biodigesterType': biodigesterType,
    'biodigesterCapacity': biodigesterCapacity,
    'cows': cows,
    'pigs': pigs,
    'goats': goats,
    'poultry': poultry,
    'wasteProduction': wasteProduction,
    'energyProduction': energyProduction,
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

  factory FeedingEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedingEntry(
      id: doc.id,
      time: data['time'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'pending',
    );
  }
}
