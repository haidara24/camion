import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'leave_shipment_public_event.dart';
part 'leave_shipment_public_state.dart';

class LeaveShipmentPublicBloc
    extends Bloc<LeaveShipmentPublicEvent, LeaveShipmentPublicState> {
  late ShipmentRepository shipmentRepository;
  LeaveShipmentPublicBloc({required this.shipmentRepository})
      : super(LeaveShipmentPublicInitial()) {
    on<LeaveShipmentPublicButtonPressed>((event, emit) async {
      emit(LeaveShipmentPublicLoadingProgressState());
      try {
        var result = await shipmentRepository.leaveShipmentPublic(
          event.shipment,
        );

        emit(LeaveShipmentPublicSuccessState(result!));
      } catch (e) {
        emit(LeaveShipmentPublicFailureState(e.toString()));
      }
    });
  }
}
