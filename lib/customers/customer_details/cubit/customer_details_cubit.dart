import 'package:bloc/bloc.dart';
import 'package:customer_repository/customer_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum CustomerDetailsStatus { loading, success, notFound, failure }

final class CustomerDetailsState extends Equatable {
  const CustomerDetailsState({
    this.status = CustomerDetailsStatus.loading,
    this.customer,
  });

  final CustomerDetailsStatus status;
  final Customer? customer;

  @override
  List<Object?> get props => [status, customer];
}

/// Loads one customer by ID, so the screen also works from a deep link and
/// handles customers that were removed or are no longer accessible.
class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  CustomerDetailsCubit({
    required this._customerRepository,
    required this._customerId,
  }) : super(const CustomerDetailsState());

  final CustomerRepository _customerRepository;
  final String _customerId;

  Future<void> load() async {
    emit(const CustomerDetailsState());
    try {
      final customer = await _customerRepository.getCustomer(_customerId);
      emit(
        customer == null
            ? const CustomerDetailsState(status: CustomerDetailsStatus.notFound)
            : CustomerDetailsState(
                status: CustomerDetailsStatus.success,
                customer: customer,
              ),
      );
    } on Object catch (error, stackTrace) {
      logE('Loading customer failed', error: error, stackTrace: stackTrace);
      emit(const CustomerDetailsState(status: CustomerDetailsStatus.failure));
    }
  }
}
