import 'package:equatable/equatable.dart';

/// {@template business}
/// Domain model for a business.
/// {@endtemplate}
class Business extends Equatable {
  /// {@macro business}
  const Business({
    required this.id,
    required this.ownerId,
    required this.name,
    this.categories = const [],
  });

  /// The unique identifier of the business (UUID).
  final String id;

  /// The unique identifier of the owner (UUID from profiles).
  final String ownerId;

  /// The name of the business.
  final String name;

  /// The list of category names associated with the business.
  final List<String> categories;

  @override
  List<Object?> get props => [id, ownerId, name, categories];
}
