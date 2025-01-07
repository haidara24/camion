part of 'k_commodity_category_bloc.dart';

sealed class KCommodityCategoryState extends Equatable {
  const KCommodityCategoryState();

  @override
  List<Object> get props => [];
}

final class KCommodityCategoryInitial extends KCommodityCategoryState {}

class KCommodityCategoryLoadingProgress extends KCommodityCategoryState {}

class KCommodityCategoryLoadedSuccess extends KCommodityCategoryState {
  final List<KCategory> commodityCategories;

  const KCommodityCategoryLoadedSuccess(this.commodityCategories);
}

class KCommodityCategoryLoadedFailed extends KCommodityCategoryState {
  final String errortext;

  const KCommodityCategoryLoadedFailed(this.errortext);
}
