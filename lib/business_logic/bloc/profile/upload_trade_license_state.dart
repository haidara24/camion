part of 'upload_trade_license_bloc.dart';

sealed class UploadTradeLicenseState extends Equatable {
  const UploadTradeLicenseState();

  @override
  List<Object> get props => [];
}

final class UploadTradeLicenseInitial extends UploadTradeLicenseState {}

class MerchantTradeLicenseUpdateLoading extends UploadTradeLicenseState {}

class MerchantTradeLicenseUpdateSuccess extends UploadTradeLicenseState {}

class MerchantTradeLicenseUpdateError extends UploadTradeLicenseState {
  final String error;

  MerchantTradeLicenseUpdateError(this.error);
}
