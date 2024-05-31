import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bottom_nav_bar_state.dart';

class BottomNavBarCubit extends Cubit<BottomNavBarState> {
  BottomNavBarCubit() : super(BottomNavBarShown());

  void emitShow() {
    Future.delayed(const Duration(milliseconds: 300)).then(
      (value) {
        emit(BottomNavBarShown());
      },
    );
  }

  void emitHide() => emit(BottomNavBarHidden());
}
