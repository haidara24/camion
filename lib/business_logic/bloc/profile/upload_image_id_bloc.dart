import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'upload_image_id_event.dart';
part 'upload_image_id_state.dart';

class UploadImageIdBloc extends Bloc<UploadImageIdEvent, UploadImageIdState> {
  late ProfileRepository profileRepository;

  UploadImageIdBloc({required this.profileRepository})
      : super(UploadImageIdInitial()) {
    on<MerchantUserImageId>((event, emit) async {
      emit(MerchantImageIdUpdateLoading());
      try {
        await profileRepository.updateMerchantImageId(
          event.imageFile,
        );
        emit(MerchantImageIdUpdateSuccess());
      } catch (e) {
        emit(MerchantImageIdUpdateError(e.toString()));
      }
    });
  }
}
