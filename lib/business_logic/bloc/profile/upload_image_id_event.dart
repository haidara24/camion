part of 'upload_image_id_bloc.dart';

sealed class UploadImageIdEvent extends Equatable {
  const UploadImageIdEvent();

  @override
  List<Object> get props => [];
}

class MerchantUserImageId extends UploadImageIdEvent {
  final File imageFile;

  MerchantUserImageId(
    this.imageFile,
  );
}
