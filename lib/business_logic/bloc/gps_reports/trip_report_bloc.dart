import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'trip_report_event.dart';
part 'trip_report_state.dart';

class TripReportBloc extends Bloc<TripReportEvent, TripReportState> {
  late GpsRepository gpsRepository;
  TripReportBloc({required this.gpsRepository}) : super(TripReportInitial()) {
    on<TripReportLoadEvent>((event, emit) async {
      emit(TripReportLoadingProgress());
      try {
        var result = await gpsRepository.getDistanceDetails(
          carId: event.imei,
          startTime: event.startTime,
          endTime: event.endTime,
        );
        emit(TripReportLoadedSuccess(result));
      } catch (e) {
        emit(TripReportLoadedFailed(e.toString()));
      }
    });
  }
}
