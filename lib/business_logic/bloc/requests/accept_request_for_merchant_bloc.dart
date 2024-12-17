import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'accept_request_for_merchant_event.dart';
part 'accept_request_for_merchant_state.dart';

class AcceptRequestForMerchantBloc
    extends Bloc<AcceptRequestForMerchantEvent, AcceptRequestForMerchantState> {
  late RequestRepository requestRepository;
  AcceptRequestForMerchantBloc({required this.requestRepository})
      : super(AcceptRequestForMerchantInitial()) {
    on<AcceptRequestButtonPressedEvent>((event, emit) async {
      emit(AcceptRequestLoadingProgressState());
      try {
        var result = await requestRepository.acceptRequestForMerchant(
          event.id,
        );

        emit(AcceptRequestForMerchantSuccessState(result));
      } catch (e) {
        emit(AcceptRequestForMerchantFailureState(e.toString()));
      }
    });
  }
}
