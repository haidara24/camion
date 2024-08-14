part of 'read_payment_instruction_bloc.dart';

sealed class ReadPaymentInstructionState extends Equatable {
  const ReadPaymentInstructionState();

  @override
  List<Object> get props => [];
}

final class ReadPaymentInstructionInitial extends ReadPaymentInstructionState {}

class ReadPaymentInstructionLoadingProgress
    extends ReadPaymentInstructionState {}

class ReadPaymentInstructionLoadedSuccess extends ReadPaymentInstructionState {
  final ShipmentPayment instruction;

  const ReadPaymentInstructionLoadedSuccess(this.instruction);
}

class ReadPaymentInstructionLoadedFailed extends ReadPaymentInstructionState {
  final String errortext;

  const ReadPaymentInstructionLoadedFailed(this.errortext);
}
