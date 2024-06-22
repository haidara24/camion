part of 'merchant_profile_bloc.dart';

sealed class MerchantProfileEvent extends Equatable {
  const MerchantProfileEvent();

  @override
  List<Object> get props => [];
}

class MerchantProfileLoad extends MerchantProfileEvent {
  final int merchant;

  MerchantProfileLoad(this.merchant);
}
