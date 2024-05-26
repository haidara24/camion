import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:equatable/equatable.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';

part 'incoming_shipments_event.dart';
part 'incoming_shipments_state.dart';

class IncomingShipmentsBloc
    extends Bloc<IncomingShipmentsEvent, IncomingShipmentsState> {
  late ShipmentRepository shipmentRepository;
  IncomingShipmentsBloc({required this.shipmentRepository})
      : super(IncomingShipmentsInitial()) {
    on<IncomingShipmentsLoadEvent>((event, emit) async {
      emit(IncomingShipmentsLoadingProgress());
      try {
        var result =
            await shipmentRepository.getDriverShipmentList(event.state);
        emit(IncomingShipmentsLoadedSuccess(result));
      } catch (e) {
        emit(IncomingShipmentsLoadedFailed(e.toString()));
      }
    });
  }
}
