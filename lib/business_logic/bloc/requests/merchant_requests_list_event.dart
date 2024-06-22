part of 'merchant_requests_list_bloc.dart';

sealed class MerchantRequestsListEvent extends Equatable {
  const MerchantRequestsListEvent();

  @override
  List<Object> get props => [];
}

class MerchantRequestsListLoadEvent extends MerchantRequestsListEvent {}
