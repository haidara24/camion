import 'package:bloc/bloc.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'reject_request_for_merchant_event.dart';
part 'reject_request_for_merchant_state.dart';

class RejectRequestForMerchantBloc
    extends Bloc<RejectRequestForMerchantEvent, RejectRequestForMerchantState> {
  late RequestRepository requestRepository;
  RejectRequestForMerchantBloc({required this.requestRepository})
      : super(RejectRequestForMerchantInitial()) {
    on<RejectRequestForMerchantButtonPressedEvent>((event, emit) async {
      emit(RejectRequestForMerchantLoadingProgressState());
      try {
        var result = await requestRepository.rejectRequestForMerchant(
          event.id,
          event.text,
        );

        emit(RejectRequestForMerchantSuccessState(result));
      } catch (e) {
        emit(RejectRequestForMerchantFailureState(e.toString()));
      }
    });
  }
}
