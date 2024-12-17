part of 'package_type_bloc.dart';

sealed class PackageTypeEvent extends Equatable {
  const PackageTypeEvent();

  @override
  List<Object> get props => [];
}

class PackageTypeLoadEvent extends PackageTypeEvent {}
