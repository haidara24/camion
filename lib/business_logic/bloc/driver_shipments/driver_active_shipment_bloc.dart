import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'driver_active_shipment_event.dart';
part 'driver_active_shipment_state.dart';

class DriverActiveShipmentBloc
    extends Bloc<DriverActiveShipmentEvent, DriverActiveShipmentState> {
  late ShipmentRepository shipmentRepository;
  DriverActiveShipmentBloc({required this.shipmentRepository})
      : super(DriverActiveShipmentInitial()) {
    on<DriverActiveShipmentLoadEvent>((event, emit) async {
      emit(DriverActiveShipmentLoadingProgress());
      try {
        var result =
            await shipmentRepository.getDriverActiveShipmentList(event.state);
        emit(DriverActiveShipmentLoadedSuccess(result));
      } catch (e) {
        emit(DriverActiveShipmentLoadedFailed(e.toString()));
      }
    });

    on<DriverActiveShipmentForOwnerLoadEvent>((event, emit) async {
      emit(DriverActiveShipmentLoadingProgress());
      try {
        var result = await shipmentRepository.getActiveDriverShipmentForOwner(
            event.state, event.driver);
        emit(DriverActiveShipmentLoadedSuccess(result));
      } catch (e) {
        emit(DriverActiveShipmentLoadedFailed(e.toString()));
      }
    });
  }
}
