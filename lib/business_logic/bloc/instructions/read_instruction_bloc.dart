import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:equatable/equatable.dart';

part 'read_instruction_event.dart';
part 'read_instruction_state.dart';

class ReadInstructionBloc
    extends Bloc<ReadInstructionEvent, ReadInstructionState> {
  late InstructionRepository instructionRepository;
  ReadInstructionBloc({required this.instructionRepository})
      : super(ReadInstructionInitial()) {
    on<ReadInstructionLoadEvent>((event, emit) async {
      emit(ReadInstructionLoadingProgress());
      try {
        var result =
            await instructionRepository.getShipmentInstruction(event.id);
        if (result != null) {
          emit(ReadInstructionLoadedSuccess(result));
        } else {
          emit(const ReadInstructionLoadedFailed("error"));
        }
      } catch (e) {
        emit(ReadInstructionLoadedFailed(e.toString()));
      }
    });
  }
}
