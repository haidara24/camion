import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:equatable/equatable.dart';

part 'read_payment_instruction_event.dart';
part 'read_payment_instruction_state.dart';

class ReadPaymentInstructionBloc
    extends Bloc<ReadPaymentInstructionEvent, ReadPaymentInstructionState> {
  late InstructionRepository instructionRepository;
  ReadPaymentInstructionBloc({required this.instructionRepository})
      : super(ReadPaymentInstructionInitial()) {
    on<ReadPaymentInstructionLoadEvent>((event, emit) async {
      emit(ReadPaymentInstructionLoadingProgress());
      try {
        print("object0");
        var result = await instructionRepository.getShipmentPayment(event.id);
        if (result != null) {
          emit(ReadPaymentInstructionLoadedSuccess(result));
        } else {
          emit(ReadPaymentInstructionLoadedFailed("error"));
        }
      } catch (e) {
        emit(ReadPaymentInstructionLoadedFailed(e.toString()));
      }
    });
  }
}
