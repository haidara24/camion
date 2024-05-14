import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_complete_list_event.dart';
part 'shipment_complete_list_state.dart';

class ShipmentCompleteListBloc
    extends Bloc<ShipmentCompleteListEvent, ShipmentCompleteListState> {
  late ShipmentRepository shipmentRepository;
  ShipmentCompleteListBloc({required this.shipmentRepository})
      : super(ShipmentCompleteListInitial()) {
    on<ShipmentCompleteListLoadEvent>((event, emit) async {
      emit(ShipmentCompleteListLoadingProgress());
      try {
        var result = await shipmentRepository.getKShipmentList("C");
        emit(ShipmentCompleteListLoadedSuccess(result));
      } catch (e) {
        emit(ShipmentCompleteListLoadedFailed(e.toString()));
      }
    });
  }
}
