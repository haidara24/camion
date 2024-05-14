import 'package:bloc/bloc.dart';
import 'package:camion/data/models/truck_type_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'truck_type_event.dart';
part 'truck_type_state.dart';

class TruckTypeBloc extends Bloc<TruckTypeEvent, TruckTypeState> {
  late ShipmentRepository shipmentRepository;
  TruckTypeBloc({required this.shipmentRepository})
      : super(TruckTypeInitial()) {
    on<TruckTypeLoadEvent>((event, emit) async {
      emit(TruckTypeLoadingProgress());
      try {
        var truckTypes = await shipmentRepository.getTruckTypes();
        emit(TruckTypeLoadedSuccess(truckTypes));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
