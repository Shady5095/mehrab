import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit instance(BuildContext context) => BlocProvider.of(context);

  List<Widget> homeLayoutScreens = [
    Container(),
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  int currentScreenIndex = 0;

  int sliderIndex = 0;

  void changeNavBar(int index) {
    if (index != currentScreenIndex) {
      currentScreenIndex = index;
      emit(ChangeNavBarState(currentIndex: currentScreenIndex));
    }
  }
}
