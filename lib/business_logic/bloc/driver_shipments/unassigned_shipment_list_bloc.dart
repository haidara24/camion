import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'unassigned_shipment_list_event.dart';
part 'unassigned_shipment_list_state.dart';

class UnassignedShipmentListBloc
    extends Bloc<UnassignedShipmentListEvent, UnassignedShipmentListState> {
  late ShipmentRepository shipmentRepository;
  UnassignedShipmentListBloc({required this.shipmentRepository})
      : super(UnassignedShipmentListInitial()) {
    on<UnassignedShipmentListLoadEvent>((event, emit) async {
      emit(UnassignedShipmentListLoadingProgress());
      try {
        var result = await shipmentRepository.getUnAssignedShipmentList();
        emit(UnassignedShipmentListLoadedSuccess(result));
      } catch (e) {
        emit(UnassignedShipmentListLoadedFailed(e.toString()));
      }
    });
  }
}
