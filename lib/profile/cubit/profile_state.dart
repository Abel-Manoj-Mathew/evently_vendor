import 'package:business_repository/business_repository.dart';
import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
  });

  final ProfileStatus status;
  final VendorProfile? profile;

  ProfileState copyWith({
    ProfileStatus? status,
    VendorProfile? profile,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [status, profile];
}
