import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'merchant_update_profile_event.dart';
part 'merchant_update_profile_state.dart';

class MerchantUpdateProfileBloc
    extends Bloc<MerchantUpdateProfileEvent, MerchantUpdateProfileState> {
  late ProfileRepository profileRepository;
  MerchantUpdateProfileBloc({required this.profileRepository})
      : super(MerchantUpdateProfileInitial()) {
    on<MerchantUpdateProfileButtonPressed>((event, emit) async {
      emit(MerchantUpdateProfileLoadingProgress());
      try {
        var result =
            await profileRepository.updateMerchant(event.merchant, event.file);
        if (result != null) {
          emit(MerchantUpdateProfileLoadedSuccess(result));
        } else {
          emit(MerchantUpdateProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(MerchantUpdateProfileLoadedFailed(e.toString()));
      }
    });
  }
}
