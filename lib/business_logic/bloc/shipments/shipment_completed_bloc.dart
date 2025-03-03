import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_completed_event.dart';
part 'shipment_completed_state.dart';

class ShipmentCompletedBloc
    extends Bloc<ShipmentCompletedEvent, ShipmentCompletedState> {
  late ShipmentRepository shipmentRepository;
  ShipmentCompletedBloc({required this.shipmentRepository})
      : super(ShipmentCompletedInitial()) {
    on<ShipmentCompletedLoadEvent>((event, emit) async {
      emit(ShipmentCompletedLoadingProgress());
      try {
        var result = await shipmentRepository.getShipmentList(event.state);
        emit(ShipmentCompletedLoadedSuccess(result));
      } catch (e) {
        emit(ShipmentCompletedLoadedFailed(e.toString()));
      }
    });
  }
}
