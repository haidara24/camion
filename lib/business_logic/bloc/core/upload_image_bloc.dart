import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'upload_image_event.dart';
part 'upload_image_state.dart';

class UploadImageBloc extends Bloc<UploadImageEvent, UploadImageState> {
  late ProfileRepository profileRepository;
  UploadImageBloc({required this.profileRepository})
      : super(UploadImageInitial()) {
    on<UpdateUserImage>((event, emit) async {
      emit(UserImageUpdateLoading());
      try {
        await profileRepository.updateUserImage(
          event.imageFile,
        );
        emit(UserImageUpdateSuccess());
      } catch (e) {
        emit(UserImageUpdateError(e.toString()));
      }
    });
  }
}
