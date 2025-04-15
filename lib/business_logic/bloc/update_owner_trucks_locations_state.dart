part of 'update_owner_trucks_locations_bloc.dart';

sealed class UpdateOwnerTrucksLocationsState extends Equatable {
  const UpdateOwnerTrucksLocationsState();

  @override
  List<Object> get props => [];
}

final class UpdateOwnerTrucksLocationsInitial
    extends UpdateOwnerTrucksLocationsState {}

class UpdateOwnerTrucksLocationsLoadingProgress
    extends UpdateOwnerTrucksLocationsState {}

class UpdateOwnerTrucksLocationsLoadedSuccess
    extends UpdateOwnerTrucksLocationsState {
  const UpdateOwnerTrucksLocationsLoadedSuccess();
}

class UpdateOwnerTrucksLocationsLoadedFailed
    extends UpdateOwnerTrucksLocationsState {
  final String error;

  const UpdateOwnerTrucksLocationsLoadedFailed(this.error);
}
