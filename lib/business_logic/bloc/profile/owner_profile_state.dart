part of 'owner_profile_bloc.dart';

sealed class OwnerProfileState extends Equatable {
  const OwnerProfileState();

  @override
  List<Object> get props => [];
}

final class OwnerProfileInitial extends OwnerProfileState {}

class OwnerProfileLoadingProgress extends OwnerProfileState {}

class OwnerProfileLoadedSuccess extends OwnerProfileState {
  final TruckOwner owner;

  const OwnerProfileLoadedSuccess(this.owner);
}

class OwnerProfileLoadedFailed extends OwnerProfileState {
  final String errortext;

  const OwnerProfileLoadedFailed(this.errortext);
}
