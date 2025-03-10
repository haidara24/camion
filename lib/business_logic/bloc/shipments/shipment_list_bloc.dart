import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';
part 'shipment_list_event.dart';
part 'shipment_list_state.dart';

class ShipmentListBloc extends Bloc<ShipmentListEvent, ShipmentListState> {
  late ShipmentRepository shipmentRepository;
  ShipmentListBloc({required this.shipmentRepository})
      : super(ShipmentListInitial()) {
    on<ShipmentListLoadEvent>((event, emit) async {
      emit(ShipmentListLoadingProgress());
      try {
        var result = await shipmentRepository.getKShipmentList(event.state);
        emit(ShipmentListLoadedSuccess(result));
      } catch (e) {
        emit(ShipmentListLoadedFailed(e.toString()));
      }
    });
  }
}
