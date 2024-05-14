import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'owner_incoming_shipments_event.dart';
part 'owner_incoming_shipments_state.dart';

class OwnerIncomingShipmentsBloc
    extends Bloc<OwnerIncomingShipmentsEvent, OwnerIncomingShipmentsState> {
  late ShipmentRepository shipmentRepository;
  OwnerIncomingShipmentsBloc({required this.shipmentRepository})
      : super(OwnerIncomingShipmentsInitial()) {
    on<OwnerIncomingShipmentsLoadEvent>((event, emit) async {
      emit(OwnerIncomingShipmentsLoadingProgress());
      try {
        var result = await shipmentRepository.getDriverShipmentListForOwner(
            event.state, event.driverId);
        emit(OwnerIncomingShipmentsLoadedSuccess(result));
      } catch (e) {
        emit(OwnerIncomingShipmentsLoadedFailed(e.toString()));
      }
    });
  }
}
