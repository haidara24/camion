part of 'owner_trucks_bloc.dart';

sealed class OwnerTrucksState extends Equatable {
  const OwnerTrucksState();

  @override
  List<Object> get props => [];
}

final class OwnerTrucksInitial extends OwnerTrucksState {}

class OwnerTrucksLoadingProgress extends OwnerTrucksState {}

class OwnerTrucksLoadedSuccess extends OwnerTrucksState {
  final List<KTruck> trucks;

  const OwnerTrucksLoadedSuccess(this.trucks);
}

class OwnerTrucksLoadedFailed extends OwnerTrucksState {
  final String errortext;

  const OwnerTrucksLoadedFailed(this.errortext);
}
