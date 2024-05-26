part of 'accept_request_for_merchant_bloc.dart';

class AcceptRequestForMerchantState extends Equatable {
  const AcceptRequestForMerchantState();

  @override
  List<Object> get props => [];
}

final class AcceptRequestForMerchantInitial
    extends AcceptRequestForMerchantState {}

class AcceptRequestLoadingProgressState extends AcceptRequestForMerchantState {}

class AcceptRequestForMerchantSuccessState
    extends AcceptRequestForMerchantState {
  final bool result;

  AcceptRequestForMerchantSuccessState(this.result);
}

class AcceptRequestForMerchantErrorState extends AcceptRequestForMerchantState {
  final String? error;
  const AcceptRequestForMerchantErrorState(this.error);
}

class AcceptRequestForMerchantFailureState
    extends AcceptRequestForMerchantState {
  final String errorMessage;

  const AcceptRequestForMerchantFailureState(this.errorMessage);
}
