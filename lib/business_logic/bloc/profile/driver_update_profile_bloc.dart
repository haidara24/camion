import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'driver_update_profile_event.dart';
part 'driver_update_profile_state.dart';

class DriverUpdateProfileBloc
    extends Bloc<DriverUpdateProfileEvent, DriverUpdateProfileState> {
  late ProfileRepository profileRepository;
  DriverUpdateProfileBloc({required this.profileRepository})
      : super(DriverUpdateProfileInitial()) {
    on<DriverUpdateProfileButtonPressed>((event, emit) async {
      emit(DriverUpdateProfileLoadingProgress());
      try {
        var result =
            await profileRepository.updateDriver(event.driver, event.file);
        if (result != null) {
          emit(DriverUpdateProfileLoadedSuccess(result));
        } else {
          emit(DriverUpdateProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(DriverUpdateProfileLoadedFailed(e.toString()));
      }
    });
  }
}
