import 'package:equatable/equatable.dart';

/// {@template vendor_profile}
/// Domain model for a vendor's profile details.
/// {@endtemplate}
class VendorProfile extends Equatable {
  /// {@macro vendor_profile}
  const VendorProfile({
    required this.businessName,
    required this.category,
    required this.location,
    required this.phone,
    required this.email,
  });

  /// The name of the business.
  final String businessName;

  /// The primary category of the business.
  final String category;

  /// The location of the business.
  final String location;

  /// The phone number of the user.
  final String phone;

  /// The email of the user.
  final String email;

  @override
  List<Object?> get props => [businessName, category, location, phone, email];
}
