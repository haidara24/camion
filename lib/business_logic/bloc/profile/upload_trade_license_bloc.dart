import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';

part 'upload_trade_license_event.dart';
part 'upload_trade_license_state.dart';

class UploadTradeLicenseBloc
    extends Bloc<UploadTradeLicenseEvent, UploadTradeLicenseState> {
  late ProfileRepository profileRepository;
  UploadTradeLicenseBloc({required this.profileRepository})
      : super(UploadTradeLicenseInitial()) {
    on<MerchantTradeLicense>((event, emit) async {
      emit(MerchantTradeLicenseUpdateLoading());
      try {
        await profileRepository.updateMerchantLicenseImage(
          event.imageFile,
        );
        emit(MerchantTradeLicenseUpdateSuccess());
      } catch (e) {
        emit(MerchantTradeLicenseUpdateError(e.toString()));
      }
    });
  }
}
