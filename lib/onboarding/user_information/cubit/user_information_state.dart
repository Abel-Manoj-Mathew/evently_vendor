import 'package:equatable/equatable.dart';

enum UserInformationStatus { initial, loading, success, failure }

class UserInformationState extends Equatable {
  const UserInformationState({
    this.status = UserInformationStatus.initial,
  });

  final UserInformationStatus status;

  UserInformationState copyWith({
    UserInformationStatus? status,
  }) {
    return UserInformationState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}
