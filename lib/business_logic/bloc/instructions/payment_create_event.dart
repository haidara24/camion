part of 'payment_create_bloc.dart';

sealed class PaymentCreateEvent extends Equatable {
  const PaymentCreateEvent();

  @override
  List<Object> get props => [];
}

class PaymentCreateButtonPressed extends PaymentCreateEvent {
  final ShipmentPayment payment;

  PaymentCreateButtonPressed(this.payment);
}
