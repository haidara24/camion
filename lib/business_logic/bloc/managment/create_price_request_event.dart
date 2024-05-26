part of 'create_price_request_bloc.dart';

sealed class CreatePriceRequestEvent extends Equatable {
  const CreatePriceRequestEvent();

  @override
  List<Object> get props => [];
}

class CreatePriceRequestButtonPressedEvent extends CreatePriceRequestEvent {
  final String name;

  CreatePriceRequestButtonPressedEvent({required this.name});
}
