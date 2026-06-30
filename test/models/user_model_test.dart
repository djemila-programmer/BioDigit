import 'package:flutter_test/flutter_test.dart';
import 'package:biodigit_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson parses complete data and applies defaults', () {
      final model = UserModel.fromJson(<String, dynamic>{
        'id': 'USR-42',
        'fullName': 'Awa Diallo',
        'email': 'awa@example.com',
        'phone': '+226 70 00 00 00',
        'farmName': 'Ferme Bio',
        'role': 'admin',
        'profileImageUrl': 'https://example.com/profile.png',
        'biodigesterType': 'Fixed-dome',
        'biodigesterCapacity': 12,
        'location': 'Ouagadougou',
        'createdAt': '2024-01-02T03:04:05.000Z',
      });

      expect(model.id, 'USR-42');
      expect(model.fullName, 'Awa Diallo');
      expect(model.email, 'awa@example.com');
      expect(model.phone, '+226 70 00 00 00');
      expect(model.farmName, 'Ferme Bio');
      expect(model.role, 'admin');
      expect(model.profileImageUrl, 'https://example.com/profile.png');
      expect(model.biodigesterType, 'Fixed-dome');
      expect(model.biodigesterCapacity, 12.0);
      expect(model.location, 'Ouagadougou');
      expect(model.createdAt, DateTime.parse('2024-01-02T03:04:05.000Z'));
    });

    test('fromJson applies default values for missing fields', () {
      final model = UserModel.fromJson(<String, dynamic>{});

      expect(model.id, '');
      expect(model.fullName, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.farmName, '');
      expect(model.role, 'user');
      expect(model.profileImageUrl, '');
      expect(model.biodigesterType, isNull);
      expect(model.biodigesterCapacity, isNull);
      expect(model.location, isNull);
      expect(model.createdAt, isNull);
    });

    test('toJson includes all keys and fallback values', () {
      final model = UserModel(
        id: 'USR-7',
        fullName: 'Mariam',
        email: 'mariam@example.com',
        phone: '12345',
        farmName: 'Farm 7',
        biodigesterType: null,
        biodigesterCapacity: 9.5,
        location: null,
        createdAt: null,
      );

      final json = model.toJson();

      expect(json, containsPair('id', 'USR-7'));
      expect(json, containsPair('fullName', 'Mariam'));
      expect(json, containsPair('email', 'mariam@example.com'));
      expect(json, containsPair('phone', '12345'));
      expect(json, containsPair('farmName', 'Farm 7'));
      expect(json, containsPair('role', 'user'));
      expect(json, containsPair('profileImageUrl', ''));
      expect(json, containsPair('biodigesterType', null));
      expect(json, containsPair('biodigesterCapacity', 9.5));
      expect(
        json,
        containsPair('location', 'Plateau Central, Burkina Faso'),
      );

      final createdAtValue = json['createdAt'];
      expect(createdAtValue, isNotNull);
      expect(DateTime.parse(createdAtValue as String), isA<DateTime>());
    });

    test('copyWith overrides only provided fields', () {
      final original = UserModel(
        id: 'USR-10',
        fullName: 'Original Name',
        email: 'original@example.com',
        phone: '111',
        farmName: 'Original Farm',
        role: 'user',
        profileImageUrl: 'original.png',
        biodigesterType: 'Type A',
        biodigesterCapacity: 4.2,
        location: 'Original Location',
        createdAt: DateTime.parse('2024-02-03T04:05:06.000Z'),
      );

      final updated = original.copyWith(
        fullName: 'Updated Name',
        phone: '222',
        role: 'manager',
        biodigesterCapacity: 5.5,
        location: 'Updated Location',
        profileImageUrl: 'updated.png',
      );

      expect(updated.id, original.id);
      expect(updated.email, original.email);
      expect(updated.createdAt, original.createdAt);
      expect(updated.fullName, 'Updated Name');
      expect(updated.phone, '222');
      expect(updated.role, 'manager');
      expect(updated.biodigesterCapacity, 5.5);
      expect(updated.location, 'Updated Location');
      expect(updated.profileImageUrl, 'updated.png');
      expect(updated.farmName, original.farmName);
      expect(updated.biodigesterType, original.biodigesterType);
    });

    test('round trips through toJson and fromJson', () {
      final original = UserModel(
        id: 'USR-99',
        fullName: 'Round Trip',
        email: 'round@example.com',
        phone: '+226 70 99 99 99',
        farmName: 'Round Farm',
        role: 'operator',
        profileImageUrl: 'avatar.png',
        biodigesterType: 'Tubular',
        biodigesterCapacity: 20.0,
        location: 'Bobo-Dioulasso',
        createdAt: DateTime.parse('2024-04-05T06:07:08.000Z'),
      );

      final roundTripped = UserModel.fromJson(
        Map<String, dynamic>.from(original.toJson()),
      );

      expect(roundTripped.id, original.id);
      expect(roundTripped.fullName, original.fullName);
      expect(roundTripped.email, original.email);
      expect(roundTripped.phone, original.phone);
      expect(roundTripped.farmName, original.farmName);
      expect(roundTripped.role, original.role);
      expect(roundTripped.profileImageUrl, original.profileImageUrl);
      expect(roundTripped.biodigesterType, original.biodigesterType);
      expect(roundTripped.biodigesterCapacity, original.biodigesterCapacity);
      expect(roundTripped.location, original.location);
      expect(roundTripped.createdAt, original.createdAt);
    });
  });
}
