import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'payment_create_event.dart';
part 'payment_create_state.dart';

class PaymentCreateBloc extends Bloc<PaymentCreateEvent, PaymentCreateState> {
  late ShippmentRerository shippmentRerository;
  PaymentCreateBloc({required this.shippmentRerository})
      : super(PaymentCreateInitial()) {
    on<PaymentCreateButtonPressed>((event, emit) async {
      emit(PaymentLoadingProgressState());
      try {
        var result =
            await shippmentRerository.createShipmentPayment(event.payment);

        emit(PaymentCreateSuccessState(result!));
      } catch (e) {
        emit(PaymentCreateFailureState(e.toString()));
      }
    });
  }
}
