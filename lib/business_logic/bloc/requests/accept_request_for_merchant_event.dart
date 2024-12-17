part of 'accept_request_for_merchant_bloc.dart';

class AcceptRequestForMerchantEvent extends Equatable {
  const AcceptRequestForMerchantEvent();

  @override
  List<Object> get props => [];
}

class AcceptRequestButtonPressedEvent extends AcceptRequestForMerchantEvent {
  final int id;

  AcceptRequestButtonPressedEvent(
    this.id,
  );
}
