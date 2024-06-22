import 'package:bloc/bloc.dart';
import 'package:camion/data/models/user_model.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'merchant_profile_event.dart';
part 'merchant_profile_state.dart';

class MerchantProfileBloc
    extends Bloc<MerchantProfileEvent, MerchantProfileState> {
  late ProfileRepository profileRepository;
  MerchantProfileBloc({required this.profileRepository})
      : super(MerchantProfileInitial()) {
    on<MerchantProfileLoad>((event, emit) async {
      emit(MerchantProfileLoadingProgress());
      try {
        var result = await profileRepository.getMerchant(event.merchant);
        if (result != null) {
          emit(MerchantProfileLoadedSuccess(result));
        } else {
          emit(MerchantProfileLoadedFailed("error"));
        }
      } catch (e) {
        emit(MerchantProfileLoadedFailed(e.toString()));
      }
    });
  }
}
