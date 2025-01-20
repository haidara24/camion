part of 'governorates_list_bloc.dart';

sealed class GovernoratesListState extends Equatable {
  const GovernoratesListState();

  @override
  List<Object> get props => [];
}

final class GovernoratesListInitial extends GovernoratesListState {}

class GovernoratesListLoadingProgress extends GovernoratesListState {}

class GovernoratesListLoadedSuccess extends GovernoratesListState {
  final List<Governorate> governorates;

  const GovernoratesListLoadedSuccess(this.governorates);
}

class GovernoratesListLoadedFailed extends GovernoratesListState {
  final String error;

  const GovernoratesListLoadedFailed(this.error);
}
