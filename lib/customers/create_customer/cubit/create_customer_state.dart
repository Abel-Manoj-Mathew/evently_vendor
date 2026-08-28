import 'package:equatable/equatable.dart';

enum CreateCustomerStatus { initial, loading, success, failure }

class CreateCustomerState extends Equatable {
  const CreateCustomerState({
    this.status = CreateCustomerStatus.initial,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.notes = '',
    this.countryCode = '+1',
  });

  final CreateCustomerStatus status;
  final String name;
  final String phone;
  final String email;
  final String notes;
  final String countryCode;

  CreateCustomerState copyWith({
    CreateCustomerStatus? status,
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? countryCode,
  }) {
    return CreateCustomerState(
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  @override
  List<Object> get props => [status, name, phone, email, notes, countryCode];
}
