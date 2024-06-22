part of 'merchant_update_profile_bloc.dart';

sealed class MerchantUpdateProfileState extends Equatable {
  const MerchantUpdateProfileState();

  @override
  List<Object> get props => [];
}

final class MerchantUpdateProfileInitial extends MerchantUpdateProfileState {}

class MerchantUpdateProfileLoadingProgress extends MerchantUpdateProfileState {}

class MerchantUpdateProfileLoadedSuccess extends MerchantUpdateProfileState {
  final Merchant merchant;

  const MerchantUpdateProfileLoadedSuccess(this.merchant);
}

class MerchantUpdateProfileLoadedFailed extends MerchantUpdateProfileState {
  final String errortext;

  const MerchantUpdateProfileLoadedFailed(this.errortext);
}
