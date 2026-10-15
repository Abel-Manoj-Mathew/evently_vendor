import 'package:bloc/bloc.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/profile/cubit/profile_state.dart';
import 'package:shared/shared.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this._businessRepository,
  }) : super(const ProfileState());

  final BusinessRepository _businessRepository;

  Future<void> fetchProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _businessRepository.getVendorProfileDetails();
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
        ),
      );
    } on Object catch (error, stackTrace) {
      logE('Loading profile failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }
}
