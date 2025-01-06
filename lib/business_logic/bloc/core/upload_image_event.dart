part of 'upload_image_bloc.dart';

sealed class UploadImageEvent extends Equatable {
  const UploadImageEvent();

  @override
  List<Object> get props => [];
}

class UpdateUserImage extends UploadImageEvent {
  final File imageFile;

  UpdateUserImage(
    this.imageFile,
  );
}
