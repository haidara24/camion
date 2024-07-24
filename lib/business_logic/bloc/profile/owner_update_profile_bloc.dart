import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_update_profile_event.dart';
part 'owner_update_profile_state.dart';

class OwnerUpdateProfileBloc
    extends Bloc<OwnerUpdateProfileEvent, OwnerUpdateProfileState> {
  late ProfileRepository profileRepository;
  OwnerUpdateProfileBloc({required this.profileRepository})
      : super(OwnerUpdateProfileInitial()) {
    on<OwnerUpdateProfileButtonPressed>((event, emit) async {
      emit(OwnerUpdateProfileLoadingProgress());
      try {
        var result =
            await profileRepository.updateOwner(event.owner, event.file);
        if (result != null) {
          emit(OwnerUpdateProfileLoadedSuccess(result));
        } else {
          emit(OwnerUpdateProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(OwnerUpdateProfileLoadedFailed(e.toString()));
      }
    });
  }
}
