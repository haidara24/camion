import 'package:bloc/bloc.dart';
import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'commodity_category_event.dart';
part 'commodity_category_state.dart';

class CommodityCategoryBloc
    extends Bloc<CommodityCategoryEvent, CommodityCategoryState> {
  late ShipmentRepository shipmentRepository;
  CommodityCategoryBloc({required this.shipmentRepository})
      : super(CommodityCategoryInitial()) {
    on<CommodityCategoryLoadEvent>((event, emit) async {
      emit(CommodityCategoryLoadingProgress());
      try {
        var categories = await shipmentRepository.getCommodityCategories();
        emit(CommodityCategoryLoadedSuccess(categories));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
