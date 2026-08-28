import 'package:equatable/equatable.dart';

/// {@template customer}
/// Domain model representing a customer.
/// {@endtemplate}
class Customer extends Equatable {
  /// {@macro customer}
  const Customer({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    this.email,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Customer] from a raw JSON Map.
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// The unique identifier of the customer.
  final String id;

  /// The ID of the business this customer belongs to.
  final String businessId;

  /// The customer's full name.
  final String name;

  /// The customer's phone number.
  final String phone;

  /// The customer's email address.
  final String? email;

  /// Additional notes about the customer.
  final String? notes;

  /// Creation timestamp.
  final DateTime? createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Returns customer initials for UI avatar (e.g., "Sarah Johnson" -> "SJ").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Converts this [Customer] into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        phone,
        email,
        notes,
        createdAt,
        updatedAt,
      ];
}
