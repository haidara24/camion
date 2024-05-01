part of 'instruction_create_bloc.dart';

sealed class InstructionCreateState extends Equatable {
  const InstructionCreateState();

  @override
  List<Object> get props => [];
}

final class InstructionCreateInitial extends InstructionCreateState {}

class InstructionLoadingProgressState extends InstructionCreateState {}

class InstructionCreateSuccessState extends InstructionCreateState {
  final Shipmentinstruction shipment;

  InstructionCreateSuccessState(this.shipment);
}

class InstructionCreateErrorState extends InstructionCreateState {
  final String? error;
  const InstructionCreateErrorState(this.error);
}

class InstructionCreateFailureState extends InstructionCreateState {
  final String errorMessage;

  const InstructionCreateFailureState(this.errorMessage);
}
