import 'package:equatable/equatable.dart';

/// Base failure class for error handling across the app.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure for database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Failure for cache operations.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Generic unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
