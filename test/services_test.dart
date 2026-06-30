import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trtravel/core/services/local_storage.dart';
import 'package:trtravel/features/offline/models/offline_models.dart';
import 'package:trtravel/features/share/models/share_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorage', () {
    test('init and basic operations', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();

      await LocalStorage.setString('test_key', 'test_value');
      expect(LocalStorage.getString('test_key'), 'test_value');

      await LocalStorage.setBool('test_bool', true);
      expect(LocalStorage.getBool('test_bool'), true);

      await LocalStorage.remove('test_key');
      expect(LocalStorage.getString('test_key'), null);
    });

    test('JSON list operations', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();

      final list = [
        {'id': '1', 'name': 'Test'},
        {'id': '2', 'name': 'Test 2'},
      ];
      await LocalStorage.setJsonList('test_list', list);
      final restored = LocalStorage.getJsonList('test_list');
      expect(restored, isNotNull);
      expect(restored!.length, 2);
      expect(restored[0]['name'], 'Test');
    });
  });

  group('Share Models - ShareLink', () {
    test('ShareLink constructor and defaults', () {
      final link = ShareLink(
        id: 'link_1',
        itineraryId: 'itinerary_1',
        code: 'ABC123',
        url: 'https://trtravel.app/share/ABC123',
      );
      expect(link.isActive, true);
      expect(link.code, 'ABC123');
    });
  });

  group('Offline Models - CacheEntry', () {
    test('CacheEntry expiry', () {
      final expired = CacheEntry(
        key: 'test_key',
        data: {'data': 'test'},
        expiry: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(expired.isExpired, true);

      final fresh = CacheEntry(
        key: 'test_key',
        data: {'data': 'test'},
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(fresh.isExpired, false);
    });
  });
}
