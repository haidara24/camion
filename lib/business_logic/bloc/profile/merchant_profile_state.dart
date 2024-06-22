part of 'merchant_profile_bloc.dart';

sealed class MerchantProfileState extends Equatable {
  const MerchantProfileState();

  @override
  List<Object> get props => [];
}

final class MerchantProfileInitial extends MerchantProfileState {}

class MerchantProfileLoadingProgress extends MerchantProfileState {}

class MerchantProfileLoadedSuccess extends MerchantProfileState {
  final Merchant merchant;

  const MerchantProfileLoadedSuccess(this.merchant);
}

class MerchantProfileLoadedFailed extends MerchantProfileState {
  final String errortext;

  const MerchantProfileLoadedFailed(this.errortext);
}
