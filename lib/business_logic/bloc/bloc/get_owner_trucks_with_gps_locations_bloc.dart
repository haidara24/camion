import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_model.dart';
import 'package:camion/data/repositories/truck_repository.dart';
import 'package:equatable/equatable.dart';

part 'get_owner_trucks_with_gps_locations_event.dart';
part 'get_owner_trucks_with_gps_locations_state.dart';

class GetOwnerTrucksWithGpsLocationsBloc extends Bloc<
    GetOwnerTrucksWithGpsLocationsEvent, GetOwnerTrucksWithGpsLocationsState> {
  late TruckRepository truckRepository;
  GetOwnerTrucksWithGpsLocationsBloc({required this.truckRepository})
      : super(GetOwnerTrucksWithGpsLocationsInitial()) {
    on<GetOwnerTrucksWithGpsLocationsLoadEvent>((event, emit) async {
      emit(GetOwnerTrucksWithGpsLocationsLoadingProgress());
      try {
        var result = await truckRepository.getTrucksWithGpsForOwner();
        emit(GetOwnerTrucksWithGpsLocationsLoadedSuccess(result));
      } catch (e) {
        emit(GetOwnerTrucksWithGpsLocationsLoadedFailed(e.toString()));
      }
    });
  }
}
