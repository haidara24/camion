import 'package:bloc/bloc.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'managment_shipment_list_event.dart';
part 'managment_shipment_list_state.dart';

class ManagmentShipmentListBloc
    extends Bloc<ManagmentShipmentListEvent, ManagmentShipmentListState> {
  late ShipmentRepository shipmentRepository;
  ManagmentShipmentListBloc({required this.shipmentRepository})
      : super(ManagmentShipmentListInitial()) {
    on<ManagmentShipmentListLoadEvent>((event, emit) async {
      emit(ManagmentShipmentListLoadingProgress());
      try {
        var result =
            await shipmentRepository.getManagmentKShipmentList(event.state);
        emit(ManagmentShipmentListLoadedSuccess(result));
      } catch (e) {
        emit(ManagmentShipmentListLoadedFailed(e.toString()));
      }
    });
  }
}
