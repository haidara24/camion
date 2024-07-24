part of 'owner_profile_bloc.dart';

sealed class OwnerProfileEvent extends Equatable {
  const OwnerProfileEvent();

  @override
  List<Object> get props => [];
}

class OwnerProfileLoad extends OwnerProfileEvent {
  final int owner;

  OwnerProfileLoad(this.owner);
}
