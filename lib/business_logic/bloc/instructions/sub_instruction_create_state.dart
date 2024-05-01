part of 'sub_instruction_create_bloc.dart';

sealed class SubInstructionCreateState extends Equatable {
  const SubInstructionCreateState();
  
  @override
  List<Object> get props => [];
}

final class SubInstructionCreateInitial extends SubInstructionCreateState {}

class SubInstructionCreateLoadingProgressState extends SubInstructionCreateState {}

class SubInstructionCreateSuccessState extends SubInstructionCreateState {
  final SubShipmentInstruction shipment;

  SubInstructionCreateSuccessState(this.shipment);
}

class SubInstructionCreateErrorState extends SubInstructionCreateState {
  final String? error;
  const SubInstructionCreateErrorState(this.error);
}

class SubInstructionCreateFailureState extends SubInstructionCreateState {
  final String errorMessage;

  const SubInstructionCreateFailureState(this.errorMessage);
}
