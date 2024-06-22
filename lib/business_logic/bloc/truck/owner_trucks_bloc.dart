import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_trucks_event.dart';
part 'owner_trucks_state.dart';

class OwnerTrucksBloc extends Bloc<OwnerTrucksEvent, OwnerTrucksState> {
  late TruckRepository truckRepository;
  OwnerTrucksBloc({required this.truckRepository})
      : super(OwnerTrucksInitial()) {
    on<OwnerTrucksLoadEvent>((event, emit) async {
      emit(OwnerTrucksLoadingProgress());
      try {
        var result = await truckRepository.getTrucksForOwner();
        emit(OwnerTrucksLoadedSuccess(result));
      } catch (e) {
        emit(OwnerTrucksLoadedFailed(e.toString()));
      }
    });
  }
}
