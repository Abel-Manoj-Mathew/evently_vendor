import 'package:bloc/bloc.dart';
import 'package:evently_vendor/onboarding/user_information/cubit/user_information_state.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

class UserInformationCubit extends Cubit<UserInformationState> {
  UserInformationCubit({
    required this._userRepository,
  }) : super(const UserInformationState());

  final UserRepository _userRepository;

  Future<void> updateProfile({
    required String id,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    emit(state.copyWith(status: UserInformationStatus.loading));
    try {
      await _userRepository.updateProfile(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      emit(state.copyWith(status: UserInformationStatus.success));
    } on Object catch (error, stackTrace) {
      logE('Saving profile failed', error: error, stackTrace: stackTrace);
      emit(state.copyWith(status: UserInformationStatus.failure));
    }
  }
}
