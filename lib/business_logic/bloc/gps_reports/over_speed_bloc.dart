import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'over_speed_event.dart';
part 'over_speed_state.dart';

class OverSpeedBloc extends Bloc<OverSpeedEvent, OverSpeedState> {
  late GpsRepository gpsRepository;
  OverSpeedBloc({required this.gpsRepository}) : super(OverSpeedInitial()) {
    on<OverSpeedLoadEvent>((event, emit) async {
      emit(OverSpeedLoadingProgress());
      try {
        var result = await gpsRepository.getOverSpeedReport(
          carId: event.imei,
          startTime: event.startTime,
          endTime: event.endTime,
        );
        emit(OverSpeedLoadedSuccess(result));
      } catch (e) {
        emit(OverSpeedLoadedFailed(e.toString()));
      }
    });
  }
}
