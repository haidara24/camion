import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'order_truck_event.dart';
part 'order_truck_state.dart';

class OrderTruckBloc extends Bloc<OrderTruckEvent, OrderTruckState> {
  late ShipmentRepository shipmentRepository;
  OrderTruckBloc({required this.shipmentRepository})
      : super(OrderTruckInitial()) {
    on<OrderTruckButtonPressed>((event, emit) async {
      emit(OrderTruckLoadingProgressState());
      try {
        var result = await shipmentRepository.assignDriver(
          event.shipment,
          event.driver,
        );
        if (result) {
          emit(OrderTruckSuccessState());
        } else {
          emit(OrderTruckFailureState("error"));
        }
      } catch (e) {
        emit(OrderTruckFailureState(e.toString()));
      }
    });
  }
}
