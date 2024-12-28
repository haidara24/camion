part of 'accept_request_for_merchant_bloc.dart';

class AcceptRequestForMerchantEvent extends Equatable {
  const AcceptRequestForMerchantEvent();

  @override
  List<Object> get props => [];
}

class AcceptRequestForMerchantButtonPressedEvent
    extends AcceptRequestForMerchantEvent {
  final int id;

  AcceptRequestForMerchantButtonPressedEvent(
    this.id,
  );
}
