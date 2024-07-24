import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'truck_active_status_event.dart';
part 'truck_active_status_state.dart';

class TruckActiveStatusBloc
    extends Bloc<TruckActiveStatusEvent, TruckActiveStatusState> {
  late TruckRepository truckRepository;
  TruckActiveStatusBloc({required this.truckRepository})
      : super(TruckActiveStatusInitial()) {
    on<LoadTruckActiveStatusEvent>((event, emit) async {
      emit(TruckActiveStatusLoadingProgress());
      try {
        var status = await truckRepository.getTruckActiveStatus();
        emit(TruckActiveStatusLoadedSuccess(status!));
        // ignore: empty_catches
      } catch (e) {
        emit(TruckActiveStatusLoadedFailed(e.toString()));
      }
    });

    on<UpdateTruckActiveStatusEvent>((event, emit) async {
      emit(TruckActiveStatusLoadingProgress());
      try {
        var status =
            await truckRepository.updateTruckActiveStatus(event.status);
        if (status != null) {
          emit(TruckActiveStatusLoadedSuccess(status));
        } else {
          emit(TruckActiveStatusLoadedFailed("e.toString()"));
        }
        // ignore: empty_catches
      } catch (e) {
        emit(TruckActiveStatusLoadedFailed(e.toString()));
      }
    });
  }
}
