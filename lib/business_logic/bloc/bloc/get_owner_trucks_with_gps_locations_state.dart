part of 'get_owner_trucks_with_gps_locations_bloc.dart';

sealed class GetOwnerTrucksWithGpsLocationsState extends Equatable {
  const GetOwnerTrucksWithGpsLocationsState();

  @override
  List<Object> get props => [];
}

final class GetOwnerTrucksWithGpsLocationsInitial
    extends GetOwnerTrucksWithGpsLocationsState {}

class GetOwnerTrucksWithGpsLocationsLoadingProgress
    extends GetOwnerTrucksWithGpsLocationsState {}

class GetOwnerTrucksWithGpsLocationsLoadedSuccess
    extends GetOwnerTrucksWithGpsLocationsState {
  final List<KTruck> trucks;

  const GetOwnerTrucksWithGpsLocationsLoadedSuccess(this.trucks);
}

class GetOwnerTrucksWithGpsLocationsLoadedFailed
    extends GetOwnerTrucksWithGpsLocationsState {
  final String errortext;

  const GetOwnerTrucksWithGpsLocationsLoadedFailed(this.errortext);
}
