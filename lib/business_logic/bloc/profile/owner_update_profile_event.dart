part of 'owner_update_profile_bloc.dart';

sealed class OwnerUpdateProfileEvent extends Equatable {
  const OwnerUpdateProfileEvent();

  @override
  List<Object> get props => [];
}

class OwnerUpdateProfileButtonPressed extends OwnerUpdateProfileEvent {
  final TruckOwner owner;
  final File? file;

  OwnerUpdateProfileButtonPressed(this.owner, this.file);
}
