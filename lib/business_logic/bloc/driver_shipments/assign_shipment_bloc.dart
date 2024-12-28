import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'assign_shipment_event.dart';
part 'assign_shipment_state.dart';

class AssignShipmentBloc
    extends Bloc<AssignShipmentEvent, AssignShipmentState> {
  late ShipmentRepository shipmentRepository;
  AssignShipmentBloc({required this.shipmentRepository})
      : super(AssignShipmentInitial()) {
    on<AssignShipmentButtonPressed>((event, emit) async {
      emit(AssignShipmentLoadingProgressState());
      try {
        var result = await shipmentRepository.assignShipment(
          event.shipment,
          event.driver,
        );
        if (result) {
          emit(AssignShipmentSuccessState());
        } else {
          emit(AssignShipmentFailureState("error"));
        }
      } catch (e) {
        emit(AssignShipmentFailureState(e.toString()));
      }
    });
  }
}
