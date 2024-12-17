import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'parking_report_event.dart';
part 'parking_report_state.dart';

class ParkingReportBloc extends Bloc<ParkingReportEvent, ParkingReportState> {
  late GpsRepository gpsRepository;
  ParkingReportBloc({required this.gpsRepository})
      : super(ParkingReportInitial()) {
    on<ParkingReportLoadEvent>((event, emit) async {
      emit(ParkingReportLoadingProgress());
      try {
        var result = await gpsRepository.getStopDetails(
          carId: event.imei,
          startTime: event.startTime,
          endTime: event.endTime,
        );
        emit(ParkingReportLoadedSuccess(result));
      } catch (e) {
        emit(ParkingReportLoadedFailed(e.toString()));
      }
    });
  }
}
