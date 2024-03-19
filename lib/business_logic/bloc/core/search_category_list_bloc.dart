import 'package:bloc/bloc.dart';
import 'package:camion/data/models/commodity_category_model.dart';
import 'package:camion/data/repositories/shipmment_repository.dart';
import 'package:equatable/equatable.dart';

part 'search_category_list_event.dart';
part 'search_category_list_state.dart';

class SearchCategoryListBloc
    extends Bloc<SearchCategoryListEvent, SearchCategoryListState> {
  late ShippmentRerository shippmentRerository;
  SearchCategoryListBloc({required this.shippmentRerository})
      : super(SearchCategoryListInitial()) {
    on<SearchKCommodityCategoryEvent>((event, emit) async {
      emit(SearchCategoryListLoadingProgress());
      try {
        var categories =
            await shippmentRerository.searchKCommodityCategories(event.query);
        emit(SearchCategoryListLoadedSuccess(categories));
        // ignore: empty_catches
      } catch (e) {}
    });
  }
}
