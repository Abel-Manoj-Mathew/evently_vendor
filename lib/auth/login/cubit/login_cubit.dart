import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void continueWithMobile() {
    emit(state.copyWith(status: LoginStatus.submitting));
    // TODO(developer): Implement actual login logic
  }
}
