import 'package:bloc/bloc.dart';
import 'package:camion/data/models/instruction_model.dart';
import 'package:camion/data/repositories/instruction_repository.dart';
import 'package:equatable/equatable.dart';

part 'sub_instruction_create_event.dart';
part 'sub_instruction_create_state.dart';

class SubInstructionCreateBloc
    extends Bloc<SubInstructionCreateEvent, SubInstructionCreateState> {
  late InstructionRepository instructionRepository;
  SubInstructionCreateBloc({required this.instructionRepository})
      : super(SubInstructionCreateInitial()) {
    on<SubInstructionCreateButtonPressed>((event, emit) async {
      emit(SubInstructionCreateLoadingProgressState());
      try {
        var result = await instructionRepository.createSubShipmentInstruction(
          event.instruction,
          event.id,
        );

        emit(SubInstructionCreateSuccessState(result!));
      } catch (e) {
        emit(SubInstructionCreateFailureState(e.toString()));
      }
    });
  }
}
