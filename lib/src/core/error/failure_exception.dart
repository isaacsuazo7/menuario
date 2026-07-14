import 'package:menuario/src/core/error/failure.dart';

/// Exception that preserves the [Failure] information.
///
/// Used to convert `Either<Failure, T>` results into exceptions consumable
/// by `AsyncValue` at provider boundaries.
class FailureException implements Exception {
  final Failure failure;

  FailureException(this.failure);

  String get message => failure.message;

  String? get code => failure.code;

  Map<String, dynamic>? get metadata => failure.metadata;

  Exception? get originalException => failure.exception;

  StackTrace? get stackTrace => failure.stackTrace;

  @override
  String toString() => failure.message;
}
