import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shipment_task_list_event.dart';
part 'shipment_task_list_state.dart';

class ShipmentTaskListBloc
    extends Bloc<ShipmentTaskListEvent, ShipmentTaskListState> {
  late ShipmentRepository shipmentRepository;
  ShipmentTaskListBloc({required this.shipmentRepository})
      : super(ShipmentTaskListInitial()) {
    on<ShipmentTaskListLoadEvent>((event, emit) async {
      emit(ShipmentRunningLoadingProgress());
      try {
        var result = await shipmentRepository.getSubShipmentListForTasks();
        emit(ShipmentTaskListLoadedSuccess(result));
      } catch (e) {
        emit(ShipmentTaskListLoadedFailed(e.toString()));
      }
    });
  }
}
