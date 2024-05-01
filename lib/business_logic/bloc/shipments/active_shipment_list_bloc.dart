import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'active_shipment_list_event.dart';
part 'active_shipment_list_state.dart';

class ActiveShipmentListBloc
    extends Bloc<ActiveShipmentListEvent, ActiveShipmentListState> {
  late ShippmentRerository shippmentRerository;
  ActiveShipmentListBloc({required this.shippmentRerository})
      : super(ActiveShipmentListInitial()) {
    on<ActiveShipmentListLoadEvent>((event, emit) async {
      emit(ActiveShipmentListLoadingProgress());
      try {
        var result = await shippmentRerository.getShipmentList("R");
        emit(ActiveShipmentListLoadedSuccess(result));
      } catch (e) {
        emit(ActiveShipmentListLoadedFailed(e.toString()));
      }
    });

    on<ActiveShipmentListRefreash>((event, emit) async {
      ActiveShipmentListLoadedSuccess currentState =
          state as ActiveShipmentListLoadedSuccess;
      emit(ActiveShipmentListLoadingProgress());
      try {
        emit(ActiveShipmentListLoadedSuccess(currentState.shipments));
      } catch (e) {
        emit(ActiveShipmentListLoadedFailed(e.toString()));
      }
    });
  }
}
