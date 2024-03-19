import 'package:bloc/bloc.dart';
import 'package:camion/data/models/kshipment_model.dart';
import 'package:camion/data/models/shipment_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'shippment_create_event.dart';
part 'shippment_create_state.dart';

class ShippmentCreateBloc
    extends Bloc<ShippmentCreateEvent, ShippmentCreateState> {
  late ShippmentRerository shippmentRerository;
  ShippmentCreateBloc({required this.shippmentRerository})
      : super(ShippmentCreateInitial()) {
    on<ShippmentCreateButtonPressed>((event, emit) async {
      emit(ShippmentLoadingProgressState());
      try {
        var result = await shippmentRerository.createKShipment(event.shipment);

        emit(ShippmentCreateSuccessState(result!));
      } catch (e) {
        emit(ShippmentCreateFailureState(e.toString()));
      }
    });
  }
}
