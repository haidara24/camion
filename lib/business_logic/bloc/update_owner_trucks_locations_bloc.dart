import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'update_owner_trucks_locations_event.dart';
part 'update_owner_trucks_locations_state.dart';

class UpdateOwnerTrucksLocationsBloc extends Bloc<
    UpdateOwnerTrucksLocationsEvent, UpdateOwnerTrucksLocationsState> {
  late TruckRepository truckRepository;
  UpdateOwnerTrucksLocationsBloc({required this.truckRepository})
      : super(UpdateOwnerTrucksLocationsInitial()) {
    on<UpdateOwnerTrucksLocationsLoadEvent>((event, emit) async {
      emit(UpdateOwnerTrucksLocationsLoadingProgress());
      try {
        var result = await truckRepository.getOwnerTrucksLocations();
        if (result) {
          emit(UpdateOwnerTrucksLocationsLoadedSuccess());
        } else {}
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
