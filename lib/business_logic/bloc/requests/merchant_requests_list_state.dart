part of 'merchant_requests_list_bloc.dart';

sealed class MerchantRequestsListState extends Equatable {
  const MerchantRequestsListState();

  @override
  List<Object> get props => [];
}

final class MerchantRequestsListInitial extends MerchantRequestsListState {}

class MerchantRequestsListLoadingProgress extends MerchantRequestsListState {}

class MerchantRequestsListLoadedSuccess extends MerchantRequestsListState {
  final List<ApprovalRequest> requests;

  const MerchantRequestsListLoadedSuccess(this.requests);
}

class MerchantRequestsListLoadedFailed extends MerchantRequestsListState {
  final String errortext;

  const MerchantRequestsListLoadedFailed(this.errortext);
}
