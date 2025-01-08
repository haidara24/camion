part of 'upload_trade_license_bloc.dart';

sealed class UploadTradeLicenseEvent extends Equatable {
  const UploadTradeLicenseEvent();

  @override
  List<Object> get props => [];
}

class MerchantTradeLicense extends UploadTradeLicenseEvent {
  final File imageFile;

  MerchantTradeLicense(
    this.imageFile,
  );
}
