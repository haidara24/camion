part of 'reject_request_for_merchant_bloc.dart';

sealed class RejectRequestForMerchantState extends Equatable {
  const RejectRequestForMerchantState();

  @override
  List<Object> get props => [];
}

final class RejectRequestForMerchantInitial
    extends RejectRequestForMerchantState {}

class RejectRequestLoadingProgressState extends RejectRequestForMerchantState {}

class RejectRequestForMerchantSuccessState
    extends RejectRequestForMerchantState {
  final bool result;

  RejectRequestForMerchantSuccessState(this.result);
}

class RejectRequestForMerchantErrorState extends RejectRequestForMerchantState {
  final String? error;
  const RejectRequestForMerchantErrorState(this.error);
}

class RejectRequestForMerchantFailureState
    extends RejectRequestForMerchantState {
  final String errorMessage;

  const RejectRequestForMerchantFailureState(this.errorMessage);
}
