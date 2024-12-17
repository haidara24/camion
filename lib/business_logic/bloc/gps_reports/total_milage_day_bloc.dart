import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'total_milage_day_event.dart';
part 'total_milage_day_state.dart';

class TotalMilageDayBloc
    extends Bloc<TotalMilageDayEvent, TotalMilageDayState> {
  late GpsRepository gpsRepository;
  TotalMilageDayBloc({required this.gpsRepository})
      : super(TotalMilageDayInitial()) {
    on<TotalMilageDayLoadEvent>((event, emit) async {
      emit(TotalMilageDayLoadingProgress());
      try {
        var result = await gpsRepository.getTruckMileageDetailsPerDay(
          carId: event.imei,
          startTime: event.startTime,
          endTime: event.endTime,
        );
        emit(TotalMilageDayLoadedSuccess(result));
      } catch (e) {
        emit(TotalMilageDayLoadedFailed(e.toString()));
      }
    });
  }
}
