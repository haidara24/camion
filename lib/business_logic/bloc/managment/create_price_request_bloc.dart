import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/price_request_repository.dart';
import 'package:equatable/equatable.dart';

part 'create_price_request_event.dart';
part 'create_price_request_state.dart';

class CreatePriceRequestBloc
    extends Bloc<CreatePriceRequestEvent, CreatePriceRequestState> {
  late PriceRequestRepository priceRequestRepository;
  CreatePriceRequestBloc({required this.priceRequestRepository})
      : super(CreatePriceRequestInitial()) {
    on<CreatePriceRequestButtonPressedEvent>((event, emit) async {
      emit(CreatePriceRequestLoadingProgress());
      try {
        var result =
            await priceRequestRepository.createPriceRequest(event.name);
        if (result) {
          emit(CreatePriceRequestLoadedSuccess());
        } else {
          emit(const CreatePriceRequestLoadedFailed("error"));
        }
      } catch (e) {
        emit(CreatePriceRequestLoadedFailed(e.toString()));
      }
    });
  }
}
