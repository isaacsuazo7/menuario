import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/firebase/firebase_bootstrap.dart';

void main() {
  group('firestorePersistenceSettings', () {
    test('should enable offline-first persistence', () {
      // Act & Assert
      expect(firestorePersistenceSettings.persistenceEnabled, isTrue);
    });

    test('should be a Settings instance ready to assign to '
        'FirebaseFirestore.instance.settings', () {
      // Act & Assert
      expect(firestorePersistenceSettings, isA<Settings>());
    });
  });
}
