part of 'create_price_request_bloc.dart';

sealed class CreatePriceRequestState extends Equatable {
  const CreatePriceRequestState();

  @override
  List<Object> get props => [];
}

final class CreatePriceRequestInitial extends CreatePriceRequestState {}

class CreatePriceRequestLoadingProgress extends CreatePriceRequestState {}

class CreatePriceRequestLoadedSuccess extends CreatePriceRequestState {}

class CreatePriceRequestLoadedFailed extends CreatePriceRequestState {
  final String error;

  const CreatePriceRequestLoadedFailed(this.error);
}
