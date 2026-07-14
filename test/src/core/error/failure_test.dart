import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';

void main() {
  group('Failure', () {
    group('construction', () {
      test('should hold message, code, exception, stackTrace and metadata', () {
        // Arrange
        final exception = Exception('boom');
        final stackTrace = StackTrace.current;

        // Act
        final failure = Failure(
          message: 'Something went wrong',
          code: 'CUSTOM_CODE',
          exception: exception,
          stackTrace: stackTrace,
          metadata: {'key': 'value'},
        );

        // Assert
        expect(failure.message, 'Something went wrong');
        expect(failure.code, 'CUSTOM_CODE');
        expect(failure.exception, exception);
        expect(failure.stackTrace, stackTrace);
        expect(failure.metadata, {'key': 'value'});
      });

      test('should allow code, exception, stackTrace and metadata to be '
          'null', () {
        // Arrange & Act
        const failure = Failure(message: 'Minimal failure');

        // Assert
        expect(failure.message, 'Minimal failure');
        expect(failure.code, isNull);
        expect(failure.exception, isNull);
        expect(failure.stackTrace, isNull);
        expect(failure.metadata, isNull);
      });
    });

    group('domain factories', () {
      test('unknownUnit should carry code and offending symbol', () {
        // Act
        final failure = Failure.unknownUnit('taza');

        // Assert
        expect(failure.code, 'unknownUnit');
        expect(failure.message, contains('taza'));
        expect(failure.metadata?['symbol'], 'taza');
      });

      test('missingConversionFactor should carry code and ingredient name', () {
        // Act
        final failure = Failure.missingConversionFactor('Avena');

        // Assert
        expect(failure.code, 'missingConversionFactor');
        expect(failure.message, contains('Avena'));
        expect(failure.metadata?['ingredientName'], 'Avena');
      });

      test('negativeStock should carry code and ingredient name', () {
        // Act
        final failure = Failure.negativeStock('Pollo');

        // Assert
        expect(failure.code, 'negativeStock');
        expect(failure.message, contains('Pollo'));
        expect(failure.metadata?['ingredientName'], 'Pollo');
      });

      test('invalidDay should carry code and offending day', () {
        // Act
        final failure = Failure.invalidDay('Dom');

        // Assert
        expect(failure.code, 'invalidDay');
        expect(failure.message, contains('Dom'));
        expect(failure.metadata?['day'], 'Dom');
      });

      test('mutateBom should carry a fixed code without metadata', () {
        // Act
        final failure = Failure.mutateBom();

        // Assert
        expect(failure.code, 'mutateBom');
        expect(failure.metadata, isNull);
      });

      test('authNoUser should carry a fixed code without metadata', () {
        // Act
        final failure = Failure.authNoUser();

        // Assert
        expect(failure.code, 'authNoUser');
        expect(failure.message, isNotEmpty);
        expect(failure.metadata, isNull);
      });

      test(
        'firestore should carry the FirebaseException code, message and '
        'the original exception',
        () {
          // Arrange
          final exception = FirebaseException(
            plugin: 'firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions.',
          );

          // Act
          final failure = Failure.firestore(exception);

          // Assert
          expect(failure.code, 'permission-denied');
          expect(failure.message, 'Missing or insufficient permissions.');
          expect(failure.exception, exception);
        },
      );

      test(
        'firestore should fall back to a default message when the '
        'FirebaseException carries none',
        () {
          // Arrange
          final exception = FirebaseException(
            plugin: 'firestore',
            code: 'unavailable',
          );

          // Act
          final failure = Failure.firestore(exception);

          // Assert
          expect(failure.code, 'unavailable');
          expect(failure.message, isNotEmpty);
        },
      );

      test('unauthenticated should carry a fixed code without metadata', () {
        // Act
        final failure = Failure.unauthenticated();

        // Assert
        expect(failure.code, 'unauthenticated');
        expect(failure.message, isNotEmpty);
        expect(failure.metadata, isNull);
      });
    });

    group('toString', () {
      test('should include message and code', () {
        // Arrange
        const failure = Failure(message: 'Oops', code: 'oops');

        // Act & Assert
        expect(failure.toString(), 'Failure(message: Oops, code: oops)');
      });
    });
  });
}
