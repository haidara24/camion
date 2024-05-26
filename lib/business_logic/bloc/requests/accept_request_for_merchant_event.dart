part of 'accept_request_for_merchant_bloc.dart';

class AcceptRequestForMerchantEvent extends Equatable {
  const AcceptRequestForMerchantEvent();

  @override
  List<Object> get props => [];
}

class AcceptRequestButtonPressedEvent extends AcceptRequestForMerchantEvent {
  final int id;
  final String text;
  final double extra;

  AcceptRequestButtonPressedEvent(this.id, this.text, this.extra);
}
