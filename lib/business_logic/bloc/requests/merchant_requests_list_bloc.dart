import 'package:bloc/bloc.dart';
import 'package:camion/data/models/approval_request.dart';
import 'package:camion/data/repositories/request_repository.dart';
import 'package:equatable/equatable.dart';

part 'merchant_requests_list_event.dart';
part 'merchant_requests_list_state.dart';

class MerchantRequestsListBloc
    extends Bloc<MerchantRequestsListEvent, MerchantRequestsListState> {
  late RequestRepository requestRepository;
  MerchantRequestsListBloc({required this.requestRepository})
      : super(MerchantRequestsListInitial()) {
    on<MerchantRequestsListLoadEvent>((event, emit) async {
      emit(MerchantRequestsListLoadingProgress());
      try {
        var result = await requestRepository.getApprovalRequestsForMerchant();

        emit(MerchantRequestsListLoadedSuccess(result));
      } catch (e) {
        emit(MerchantRequestsListLoadedFailed(e.toString()));
      }
    });
  }
}
