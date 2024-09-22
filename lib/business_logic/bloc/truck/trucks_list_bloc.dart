import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'trucks_list_event.dart';
part 'trucks_list_state.dart';

class TrucksListBloc extends Bloc<TrucksListEvent, TrucksListState> {
  late TruckRepository truckRepository;
  TrucksListBloc({required this.truckRepository})
      : super(TrucksListLoadedSuccess([])) {
    on<TrucksListLoadEvent>((event, emit) async {
      emit(TrucksListLoadingProgress());
      try {
        var result = await truckRepository.getTrucks(event.truckType);
        emit(TrucksListLoadedSuccess(result));
      } catch (e) {
        emit(TrucksListLoadedFailed(e.toString()));
      }
    });

    on<NearestTrucksListLoadEvent>((event, emit) async {
      emit(TrucksListLoadingProgress());
      try {
        var result = await truckRepository.getNearestTrucks(
          event.truckType,
          event.location,
          event.pol,
          event.pod,
        );
        emit(TrucksListLoadedSuccess(result));
      } catch (e) {
        emit(TrucksListLoadedFailed(e.toString()));
      }
    });

    on<TrucksListSearchEvent>((event, emit) async {
      emit(TrucksListLoadingProgress());
      try {
        var result = await truckRepository.searchKTrucks(event.truckType);
        emit(TrucksListLoadedSuccess(result));
      } catch (e) {
        emit(TrucksListLoadedFailed(e.toString()));
      }
    });
  }
}
