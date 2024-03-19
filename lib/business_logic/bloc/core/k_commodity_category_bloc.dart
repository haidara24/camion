import 'package:bloc/bloc.dart';
import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'k_commodity_category_event.dart';
part 'k_commodity_category_state.dart';

class KCommodityCategoryBloc
    extends Bloc<KCommodityCategoryEvent, KCommodityCategoryState> {
  late ShippmentRerository shippmentRerository;
  KCommodityCategoryBloc({required this.shippmentRerository})
      : super(KCommodityCategoryInitial()) {
    on<KCommodityCategoryLoadEvent>((event, emit) async {
      emit(KCommodityCategoryLoadingProgress());
      try {
        var categories = await shippmentRerository.getKCommodityCategories();
        emit(KCommodityCategoryLoadedSuccess(categories));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
