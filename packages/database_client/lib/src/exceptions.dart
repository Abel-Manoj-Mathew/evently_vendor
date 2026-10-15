/// {@template duplicate_record_exception}
/// The database rejected a write because it violates a unique constraint.
/// {@endtemplate}
class DuplicateRecordException implements Exception {
  /// {@macro duplicate_record_exception}
  const DuplicateRecordException(this.error);

  /// The underlying database error.
  final Object error;
}
