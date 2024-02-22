import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'inprogress_shipments_event.dart';
part 'inprogress_shipments_state.dart';

class InprogressShipmentsBloc
    extends Bloc<InprogressShipmentsEvent, InprogressShipmentsState> {
  late ShippmentRerository shippmentRerository;
  InprogressShipmentsBloc({required this.shippmentRerository})
      : super(InprogressShipmentsInitial()) {
    on<InprogressShipmentsLoadEvent>((event, emit) async {
      emit(InprogressShipmentsLoadingProgress());
      try {
        var result =
            await shippmentRerository.getDriverShipmentList(event.state);
        emit(InprogressShipmentsLoadedSuccess(result));
      } catch (e) {
        emit(InprogressShipmentsLoadedFailed(e.toString()));
      }
    });
  }
}
