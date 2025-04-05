import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'car_gps_status_details_event.dart';
part 'car_gps_status_details_state.dart';

class CarGpsStatusDetailsBloc
    extends Bloc<CarGpsStatusDetailsEvent, CarGpsStatusDetailsState> {
  CarGpsStatusDetailsBloc() : super(CarGpsStatusDetailsInitial()) {
    on<CarGpsStatusDetailsButtonPressed>((event, emit) async {
      emit(CarGpsStatusDetailsLoadingProgress());
      try {
        var result = await GpsRepository.getCarInfo(
          event.imei,
        );
        if (result != null) {
          emit(CarGpsStatusDetailsLoadedSuccess(result));
        } else {
          emit(CarGpsStatusDetailsLoadedFailed("error"));
        }
      } catch (e) {
        emit(CarGpsStatusDetailsLoadedFailed(e.toString()));
      }
    });
  }
}
