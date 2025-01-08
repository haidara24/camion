part of 'upload_image_id_bloc.dart';

sealed class UploadImageIdState extends Equatable {
  const UploadImageIdState();

  @override
  List<Object> get props => [];
}

final class UploadImageIdInitial extends UploadImageIdState {}

class MerchantImageIdUpdateLoading extends UploadImageIdState {}

class MerchantImageIdUpdateSuccess extends UploadImageIdState {}

class MerchantImageIdUpdateError extends UploadImageIdState {
  final String error;

  MerchantImageIdUpdateError(this.error);
}
