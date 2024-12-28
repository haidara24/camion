part of 'reject_request_for_merchant_bloc.dart';

sealed class RejectRequestForMerchantEvent extends Equatable {
  const RejectRequestForMerchantEvent();

  @override
  List<Object> get props => [];
}

class RejectRequestForMerchantButtonPressedEvent
    extends RejectRequestForMerchantEvent {
  final int id;
  final String text;

  RejectRequestForMerchantButtonPressedEvent(this.id, this.text);
}
