import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_profile_event.dart';
part 'owner_profile_state.dart';

class OwnerProfileBloc extends Bloc<OwnerProfileEvent, OwnerProfileState> {
  late ProfileRepository profileRepository;
  OwnerProfileBloc({required this.profileRepository})
      : super(OwnerProfileInitial()) {
    on<OwnerProfileLoad>((event, emit) async {
      emit(OwnerProfileLoadingProgress());
      try {
        var result = await profileRepository.getOwner(event.owner);
        if (result != null) {
          emit(OwnerProfileLoadedSuccess(result));
        } else {
          emit(OwnerProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(OwnerProfileLoadedFailed(e.toString()));
      }
    });
  }
}
