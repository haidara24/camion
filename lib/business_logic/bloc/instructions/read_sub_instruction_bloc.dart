import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:equatable/equatable.dart';

part 'read_sub_instruction_event.dart';
part 'read_sub_instruction_state.dart';

class ReadSubInstructionBloc
    extends Bloc<ReadSubInstructionEvent, ReadSubInstructionState> {
  late InstructionRepository instructionRepository;
  ReadSubInstructionBloc({required this.instructionRepository})
      : super(ReadSubInstructionInitial()) {
    on<ReadSubInstructionLoadEvent>((event, emit) async {
      emit(ReadSubInstructionLoadingProgress());
      try {
        var result = await instructionRepository.getSubShipmentInstruction(
            event.id, event.subId);
        if (result != null) {
          emit(ReadSubInstructionLoadedSuccess(result));
        } else {
          emit(ReadSubInstructionLoadedFailed("error"));
        }
      } catch (e) {
        emit(ReadSubInstructionLoadedFailed(e.toString()));
      }
    });
  }
}
