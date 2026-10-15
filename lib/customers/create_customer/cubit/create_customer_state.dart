part of 'create_customer_cubit.dart';

enum CreateCustomerStatus {
  editing,
  saving,
  duplicateWarning,
  success,
  failure,
}

enum CreateCustomerFailure {
  /// The signed-in user has no business to attach the customer to.
  noBusiness,

  /// The database still enforces unique phone numbers (pre-0004 schema).
  phoneAlreadyUsed,

  unknown,
}

final class CreateCustomerState extends Equatable {
  const CreateCustomerState({
    this.status = CreateCustomerStatus.editing,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.notes = '',
    this.showValidation = false,
    this.duplicates = const [],
    this.duplicatesAcknowledged = false,
    this.createdCustomer,
    this.failure,
  });

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final CreateCustomerStatus status;
  final String name;
  final String phone;
  final String email;
  final String notes;

  /// Whether to display field errors (after the first submit attempt).
  final bool showValidation;

  /// Existing customers whose phone matches [phone].
  final List<Customer> duplicates;

  /// The user chose to create a new customer despite [duplicates].
  final bool duplicatesAcknowledged;

  final Customer? createdCustomer;
  final CreateCustomerFailure? failure;

  bool get isBusy => status == CreateCustomerStatus.saving;

  String? get nameError =>
      name.trim().isEmpty ? 'Customer name is required' : null;

  String? get phoneError => CustomerPhone.isValid(phone)
      ? null
      : 'Enter a valid phone number, or leave it empty';

  String? get emailError =>
      email.trim().isEmpty || _email.hasMatch(email.trim())
      ? null
      : 'Enter a valid email address, or leave it empty';

  bool get isValid =>
      nameError == null && phoneError == null && emailError == null;

  CreateCustomerState copyWith({
    CreateCustomerStatus? status,
    String? name,
    String? phone,
    String? email,
    String? notes,
    bool? showValidation,
    List<Customer>? duplicates,
    bool? duplicatesAcknowledged,
    Customer? createdCustomer,
    CreateCustomerFailure? failure,
  }) {
    return CreateCustomerState(
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      showValidation: showValidation ?? this.showValidation,
      duplicates: duplicates ?? this.duplicates,
      duplicatesAcknowledged:
          duplicatesAcknowledged ?? this.duplicatesAcknowledged,
      createdCustomer: createdCustomer ?? this.createdCustomer,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    name,
    phone,
    email,
    notes,
    showValidation,
    duplicates,
    duplicatesAcknowledged,
    createdCustomer,
    failure,
  ];
}
