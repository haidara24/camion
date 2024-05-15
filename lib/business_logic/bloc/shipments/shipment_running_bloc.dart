import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_running_event.dart';
part 'shipment_running_state.dart';

class ShipmentRunningBloc
    extends Bloc<ShipmentRunningEvent, ShipmentRunningState> {
  late ShipmentRepository shipmentRepository;
  ShipmentRunningBloc({required this.shipmentRepository})
      : super(ShipmentRunningInitial()) {
    on<ShipmentRunningLoadEvent>((event, emit) async {
      emit(ShipmentRunningLoadingProgress());
      try {
        var result = await shipmentRepository.getSubShipmentList(event.state);
        emit(ShipmentRunningLoadedSuccess(result));
      } catch (e) {
        emit(ShipmentRunningLoadedFailed(e.toString()));
      }
    });
  }
}
