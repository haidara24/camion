part of 'fix_type_list_bloc.dart';

sealed class FixTypeListState extends Equatable {
  const FixTypeListState();

  @override
  List<Object> get props => [];
}

final class FixTypeListInitial extends FixTypeListState {}

class FixTypeListLoadingProgress extends FixTypeListState {}

class FixTypeListLoadedSuccess extends FixTypeListState {
  final List<ExpenseType> types;

  const FixTypeListLoadedSuccess(this.types);
}

class FixTypeListLoadedFailed extends FixTypeListState {
  final String errorstring;

  FixTypeListLoadedFailed(this.errorstring);
}
