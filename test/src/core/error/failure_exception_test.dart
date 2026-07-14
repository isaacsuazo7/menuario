import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';

void main() {
  group('FailureException', () {
    test('should wrap a Failure and implement Exception', () {
      // Arrange
      const failure = Failure(message: 'Test error message', code: 'TEST');

      // Act
      final exception = FailureException(failure);

      // Assert
      expect(exception, isA<Exception>());
      expect(exception.failure, failure);
    });

    test('should proxy message, code, metadata, exception and stackTrace', () {
      // Arrange
      final originalException = Exception('boom');
      final stackTrace = StackTrace.current;
      final failure = Failure(
        message: 'Original message',
        code: 'ORIGINAL_CODE',
        exception: originalException,
        stackTrace: stackTrace,
        metadata: {'key': 'value'},
      );

      // Act
      final exception = FailureException(failure);

      // Assert
      expect(exception.message, 'Original message');
      expect(exception.code, 'ORIGINAL_CODE');
      expect(exception.metadata, {'key': 'value'});
      expect(exception.originalException, originalException);
      expect(exception.stackTrace, stackTrace);
    });

    test('toString should return the wrapped failure message', () {
      // Arrange
      const failure = Failure(message: 'Wrapped message');

      // Act
      final exception = FailureException(failure);

      // Assert
      expect(exception.toString(), 'Wrapped message');
    });
  });
}
