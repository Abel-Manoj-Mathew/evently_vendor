import 'package:bloc/bloc.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.businessRepository,
  }) : super(const ProfileState());

  final BusinessRepository businessRepository;

  Future<void> fetchProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await businessRepository.getVendorProfileDetails();
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
        ),
      );
    } catch (e, stackTrace) {
      print('DEBUG: Profile fetch failed: $e\n$stackTrace');
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }
}
