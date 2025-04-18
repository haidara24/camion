import 'package:bloc/bloc.dart';
import 'package:camion/data/models/shipmentv2_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'package_type_event.dart';
part 'package_type_state.dart';

class PackageTypeBloc extends Bloc<PackageTypeEvent, PackageTypeState> {
  late ShipmentRepository shipmentRepository;
  PackageTypeBloc({required this.shipmentRepository})
      : super(PackageTypeInitial()) {
    on<PackageTypeLoadEvent>((event, emit) async {
      emit(PackageTypeLoadingProgress());
      try {
        var packageTypes = await shipmentRepository.getPackageTypes();
        emit(PackageTypeLoadedSuccess(packageTypes));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
