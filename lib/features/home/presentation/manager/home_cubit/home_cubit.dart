import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';

import '../../../../../core/utilities/resources/constants.dart';
import '../../../../teachers/presentation/screens/teachers_screen.dart';
import '../../views/home_view.dart';
import '../../views/more_screen.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit instance(BuildContext context) => BlocProvider.of(context);
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Widget> homeLayoutScreens = [
    HomeView(),
    TeachersScreen(),
    Container(),
    MoreScreen(),
  ];

  int currentScreenIndex = 0;

  int sliderIndex = 0;

  void changeNavBar(int index) {
    if (index != currentScreenIndex) {
      currentScreenIndex = index;
      if(index == 0){
        getFavoriteTeachersCount();
        getStudentsCount();
        //getNotificationsCount();
      }
      emit(ChangeNavBarState(currentIndex: currentScreenIndex));
    }
  }

  UserModel? userModel;

  Future<void> getUserData() async {
    String? uid = CacheService.uid;
    if(uid == null || uid.isEmpty){
      return;
    }
    if(userModel != null) {
      return;
    }
    emit(GetUserDataWaitingState());
   await db.collection("users").doc(uid).get().then((value) async {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()??{});
        await cacheRole(userModel?.userRole??'');
        myUid = uid;
        currentUserModel = userModel;
        if(userModel?.userRole == "admin"){
          AppConstants.isAdmin = true;
        }else if(userModel?.userRole == "teacher") {
          AppConstants.isTeacher = true;
        }else{
          AppConstants.isStudent = true;
        }

        await getFavoriteTeachersCount();
        getStudentsCount();
        getNotificationsCount();
        emit(GetUserDataSuccessState());
      } else {
        emit(GetUserDataErrorState("User data not found"));
        printWithColor("User data not found");
      }
    }).catchError((error) {
      emit(GetUserDataErrorState(error.toString()));
      printWithColor(error.toString());
    });
  }
  Future<void> cacheRole(String role) async {
    if(CacheService.getData(key: AppConstants.userRole) == role){
      return;
    }
    await CacheService.setData(key: AppConstants.userRole, value: role).then((value) {
      if (value == true) {
        CacheService.userRole = CacheService.getData(key: AppConstants.userRole);
      }
    });
    AppFirebaseNotification.subscribeToTopic(userModel?.userRole??'');
  }

  void setupFirebase(BuildContext context) {
    AppFirebaseNotification.initNotification(context,this);
  }
  void changeSliderIndex(int index) {
    sliderIndex = index;
    emit(ChangeSliderIndexState(index));
  }

  int favoriteTeachersCount = 0;
  int studentsCount = 0;
  Future<void> getFavoriteTeachersCount() async {
    try {
      final snapshot = await db
          .collection('users')
          .doc(myUid)
          .collection('favoriteTeachers')
          .count()
          .get();
      favoriteTeachersCount = snapshot.count??0;
      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting favorite teachers count: $e');
    }
  }
  Future<void> getStudentsCount() async {
    if(!AppConstants.isAdmin){
      return;
    }
    try {
      final snapshot = await db
          .collection('users')
          .where("userRole", isEqualTo: "student")
          .count()
          .get();
      studentsCount = snapshot.count??0;
      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting students count: $e');
    }
  }
  int? notificationsCount;
  Future<void> getNotificationsCount() async {
    if(AppConstants.isAdmin){
      return;
    }
    try {
      getNotificationsCurrentQuery.then((snapshot) {
        notificationsCount = snapshot.count??0;
        emit(ToggleTeacherFavSuccessState());
      });
    } catch (e) {
      printWithColor('$e');
    }
  }
  Future<AggregateQuerySnapshot> get getNotificationsCurrentQuery {
    final studentsQuery =  FirebaseFirestore.instance
        .collection('notifications')
        .where('role', whereIn: ['all', 'students',myUid])
        .orderBy("timestamp", descending: true)
        .count().get();
    final teachersQuery =  FirebaseFirestore.instance
        .collection('notifications')
        .where('role', whereIn: ['all', 'teachers'])
        .orderBy("timestamp", descending: true)
        .count().get();
    if(AppConstants.isStudent) {
      return studentsQuery;
    }else{
      return teachersQuery;
    }
  }

  void refreshNotifications() {
    emit(NotificationsRefresh());
  }
}
