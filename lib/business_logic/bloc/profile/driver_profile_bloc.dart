import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'driver_profile_event.dart';
part 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  late ProfileRepository profileRepository;
  DriverProfileBloc({required this.profileRepository})
      : super(DriverProfileInitial()) {
    on<DriverProfileLoad>((event, emit) async {
      emit(DriverProfileLoadingProgress());
      try {
        var result = await profileRepository.getDriver(event.driver);
        if (result != null) {
          emit(DriverProfileLoadedSuccess(result));
        } else {
          emit(DriverProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(DriverProfileLoadedFailed(e.toString()));
      }
    });
  }
}
