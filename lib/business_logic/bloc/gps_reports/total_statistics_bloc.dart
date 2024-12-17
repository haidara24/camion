import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/gps_repository.dart';
import 'package:equatable/equatable.dart';

part 'total_statistics_event.dart';
part 'total_statistics_state.dart';

class TotalStatisticsBloc
    extends Bloc<TotalStatisticsEvent, TotalStatisticsState> {
  late GpsRepository gpsRepository;
  TotalStatisticsBloc({required this.gpsRepository})
      : super(TotalStatisticsInitial()) {
    on<TotalStatisticsLoadEvent>((event, emit) async {
      emit(TotalStatisticsLoadingProgress());
      print("loading");
      try {
        var result = await gpsRepository.getStatisticsData(
          carId: event.imei,
          startTime: event.startTime,
          endTime: event.endTime,
        );
        emit(TotalStatisticsLoadedSuccess(result));
      } catch (e) {
        emit(TotalStatisticsLoadedFailed(e.toString()));
      }
    });
  }
}
