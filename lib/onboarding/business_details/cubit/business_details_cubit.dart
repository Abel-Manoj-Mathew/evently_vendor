import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:business_repository/business_repository.dart';
import 'package:evently_vendor/onboarding/business_details/cubit/business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  BusinessDetailsCubit({
    required this._businessRepository,
  }) : super(const BusinessDetailsState()) {
    unawaited(_fetchCategories());
  }

  final BusinessRepository _businessRepository;

  Future<void> _fetchCategories() async {
    emit(state.copyWith(status: BusinessDetailsStatus.loadingCategories));
    try {
      final categories = await _businessRepository.getCategories();
      emit(
        state.copyWith(
          status: BusinessDetailsStatus.initial,
          categories: categories,
        ),
      );
    } on Object catch (_) {
      emit(state.copyWith(status: BusinessDetailsStatus.failure));
    }
  }

  Future<void> createBusiness({
    required String ownerId,
    required String businessName,
    required List<String> categories,
  }) async {
    emit(state.copyWith(status: BusinessDetailsStatus.loading));
    try {
      await _businessRepository.createBusiness(
        ownerId: ownerId,
        businessName: businessName,
        categories: categories,
      );
      emit(state.copyWith(status: BusinessDetailsStatus.success));
    } on Object catch (e, stackTrace) {
      print('CreateBusiness Error: $e');
      print(stackTrace);
      emit(state.copyWith(status: BusinessDetailsStatus.failure));
    }
  }
}
