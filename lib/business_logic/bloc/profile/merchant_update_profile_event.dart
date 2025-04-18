part of 'merchant_update_profile_bloc.dart';

sealed class MerchantUpdateProfileEvent extends Equatable {
  const MerchantUpdateProfileEvent();

  @override
  List<Object> get props => [];
}

class MerchantUpdateProfileButtonPressed extends MerchantUpdateProfileEvent {
  final Merchant merchant;
  final File? file;

  MerchantUpdateProfileButtonPressed(this.merchant, this.file);
}
