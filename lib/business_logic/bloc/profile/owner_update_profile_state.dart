part of 'owner_update_profile_bloc.dart';

sealed class OwnerUpdateProfileState extends Equatable {
  const OwnerUpdateProfileState();

  @override
  List<Object> get props => [];
}

final class OwnerUpdateProfileInitial extends OwnerUpdateProfileState {}

class OwnerUpdateProfileLoadingProgress extends OwnerUpdateProfileState {}

class OwnerUpdateProfileLoadedSuccess extends OwnerUpdateProfileState {
  final TruckOwner owner;

  const OwnerUpdateProfileLoadedSuccess(this.owner);
}

class OwnerUpdateProfileLoadedFailed extends OwnerUpdateProfileState {
  final String errortext;

  const OwnerUpdateProfileLoadedFailed(this.errortext);
}
