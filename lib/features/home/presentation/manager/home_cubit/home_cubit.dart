import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/print_with_color.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/utilities/services/firebase_notification.dart';
import 'package:mehrab/features/authentication/data/user_model.dart';
import 'package:mehrab/features/sessions/presentation/screens/sessions_screen.dart';
import 'package:mehrab/features/students/presentation/screens/students_screen.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';
import '../../../../../core/utilities/functions/toast.dart';
import '../../../../../core/utilities/resources/constants.dart';
import '../../../../teacher_call/data/models/call_model.dart';
import '../../../../teacher_call/presentation/screens/calls_screen.dart';
import '../../../../teacher_call/presentation/widgets/incoming_call_dialog.dart';
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
    SessionsScreen(),
    MoreScreen(),
  ];
  List<Widget> homeLayoutScreensForTeachers = [
    HomeView(),
    StudentsScreen(isShowBackButton: false),
    CallsScreen(),
    SessionsScreen(),
    MoreScreen(),
  ];

  int currentScreenIndex = 0;

  int sliderIndex = 0;

  void changeNavBar(int index) {
    if (index != currentScreenIndex) {
      currentScreenIndex = index;
      if (index == 0) {
        getFavoriteTeachersCount();
        getStudentsCount();
        //getNotificationsCount();
      }
      emit(ChangeNavBarState(currentIndex: currentScreenIndex));
    }
  }

  UserModel? userModel;
  TeacherModel? teacherModel;

  Future<void> getUserData(BuildContext context) async {
    String? uid = CacheService.uid;
    if (uid == null || uid.isEmpty) {
      return;
    }
    if (userModel != null) {
      return;
    }
    emit(GetUserDataWaitingState());
    await db
        .collection("users")
        .doc(uid)
        .get()
        .then((value) async {
          if (value.exists) {
            userModel = UserModel.fromJson(value.data() ?? {});
            await cacheRole(userModel?.userRole ?? '');
            myUid = uid;
            currentUserModel = userModel;
            if (userModel?.userRole == "admin") {
              AppConstants.isAdmin = true;
            } else if (userModel?.userRole == "teacher") {
              AppConstants.isTeacher = true;
              teacherModel = TeacherModel.fromJson(value.data() ?? {});
              currentTeacherModel = teacherModel;
              favoriteStudentsCount =
                  teacherModel?.favoriteStudentsUid.length ?? 0;
              teacherAvailability = teacherModel?.isOnline ?? false;
              getTeacherRatingAndComments();
              if(context.mounted){
                listenToTeacherNewCalls(context);
              }
              getMissedCallsCount();
            } else {
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
        })
        .catchError((error) {
          emit(GetUserDataErrorState(error.toString()));
          printWithColor(error.toString());
        });
  }

  Future<void> cacheRole(String role) async {
    if (CacheService.getData(key: AppConstants.userRole) == role) {
      return;
    }
    await CacheService.setData(key: AppConstants.userRole, value: role).then((
      value,
    ) {
      if (value == true) {
        CacheService.userRole = CacheService.getData(
          key: AppConstants.userRole,
        );
      }
    });
    AppFirebaseNotification.subscribeToTopic(userModel?.userRole ?? '');
  }

  void setupFirebase(BuildContext context) {
    AppFirebaseNotification.initNotification(context, this);
  }

  void changeSliderIndex(int index) {
    sliderIndex = index;
    emit(ChangeSliderIndexState(index));
  }

  int favoriteTeachersCount = 0;
  int studentsCount = 0;

  Future<void> getFavoriteTeachersCount() async {
    if (AppConstants.isTeacher) {
      return;
    }
    try {
      final snapshot =
          await db
              .collection('users')
              .doc(myUid)
              .collection('favoriteTeachers')
              .count()
              .get();
      favoriteTeachersCount = snapshot.count ?? 0;
      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting favorite teachers count: $e');
    }
  }

  Future<void> getStudentsCount() async {
    if (!AppConstants.isAdmin) {
      return;
    }
    try {
      final snapshot =
          await db
              .collection('users')
              .where("userRole", isEqualTo: "student")
              .count()
              .get();
      studentsCount = snapshot.count ?? 0;
      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting students count: $e');
    }
  }

  int? notificationsCount;

  Future<void> getNotificationsCount() async {
    if (AppConstants.isAdmin) {
      return;
    }
    try {
      getNotificationsCurrentQuery.then((snapshot) {
        notificationsCount = snapshot.count ?? 0;
        emit(ToggleTeacherFavSuccessState());
      });
    } catch (e) {
      printWithColor('$e');
    }
  }

  int missedCallsCount = 0;

  Future<void> getMissedCallsCount() async {
    try {
      final snapshot =
          await db
              .collection('calls')
              .where('teacherUid', isEqualTo: myUid)
              .where("status", isEqualTo: "missed")
              .count()
              .get();
      missedCallsCount = snapshot.count ?? 0;

      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting students count: $e');
    }
  }

  Future<AggregateQuerySnapshot> get getNotificationsCurrentQuery {
    final studentsQuery =
        FirebaseFirestore.instance
            .collection('notifications')
            .where('role', whereIn: ['all', 'students', myUid])
            .orderBy("timestamp", descending: true)
            .count()
            .get();
    final teachersQuery =
        FirebaseFirestore.instance
            .collection('notifications')
            .where('role', whereIn: ['all', 'teachers'])
            .orderBy("timestamp", descending: true)
            .count()
            .get();
    if (AppConstants.isStudent) {
      return studentsQuery;
    } else {
      return teachersQuery;
    }
  }

  void refreshNotifications() {
    emit(NotificationsRefresh());
  }

  int favoriteStudentsCount = 0;
  int teacherRatingAndComments = 0;

  Future<void> getTeacherRatingAndComments() async {
    try {
      final snapshot =
          await db
              .collection('users')
              .doc(myUid)
              .collection("comments")
              .count()
              .get();
      teacherRatingAndComments = snapshot.count ?? 0;
      emit(ToggleTeacherFavSuccessState());
    } catch (e) {
      printWithColor('Error getting students count: $e');
    }
  }

  bool teacherAvailability = false;

  void changeTeacherAvailability(bool value, BuildContext context) {
    teacherAvailability = value;
    db
        .collection('users')
        .doc(myUid)
        .update({"isOnline": teacherAvailability,'isBusy': false})
        .then((value) {
          if (!context.mounted) return;
          if (teacherAvailability) {
            myToast(
              msg: AppStrings.youAreNowAvailable.tr(context),
              state: ToastStates.success,
            );
          } else {
            myToast(
              msg: AppStrings.youAreNowNotAvailable.tr(context),
              state: ToastStates.normal,
            );
            setLastActive();
          }
        })
        .catchError((error) {
          teacherAvailability = !teacherAvailability;
          myToast(
            msg: "Failed to update availability",
            state: ToastStates.error,
          );
        });
    notifyMyFavStudentsAboutMyAvailability();
    emit(ChangeTeacherAvailabilityState());
  }

  void notifyMyFavStudentsAboutMyAvailability() {
    if (!teacherAvailability) {
      return;
    }
    for (var studentUid in teacherModel?.favoriteStudentsUid ?? []) {
      AppFirebaseNotification.pushNotification(
        topic: studentUid,
        // only take the first name and second if the name contains spaces
        title: "المعلم ${teacherModel?.name.split(' ').take(3).join(' ')} متاح الآن🟢",
        dataInNotification: {},
        body: "يمكنك الآن بدء جلسة معه.",
      );
    }
  }
  void setLastActive() {
    db.collection('users').doc(myUid).update({
      "lastActive": FieldValue.serverTimestamp(),
    });
  }


  bool _isDialogShowing = false; // Tracks if a dialog is currently shown

  void listenToTeacherNewCalls(BuildContext context) {
    db
        .collection("calls")
        .where("teacherUid", isEqualTo: currentTeacherModel?.uid)
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((event) {
          if (event.docs.isNotEmpty) {
            if ((event.docs.first.data()['status'] == 'ringing') &&
                !_isDialogShowing) {
              if (!context.mounted) return;
              _isDialogShowing = true; // Set flag to prevent multiple dialogs
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return IncomingCallDialog(
                    cubit: this,
                    model: CallModel.fromJson({
                      ...event.docs.first.data(),
                      'callId': event.docs.first.id,
                    }),
                  );
                },
              ).then((_) {
                _isDialogShowing = false; // Reset flag when dialog is dismissed
              });
            }
            if ((event.docs.first.data()['status'] == 'missed') &&
                _isDialogShowing) {
              if (!context.mounted) return;
              _isDialogShowing = false; // Reset flag when dialog is dismissed
              Navigator.of(
                context,
              ).pop(); // Close the dialog if the call is missed
              getMissedCallsCount();
            }
          }
        });
  }

  Future<void> declineCall(String callDocId) async {
    await db
        .collection("calls")
        .doc(callDocId)
        .update({"status": "declined"})
        .then((value) {})
        .catchError((error) {});
  }

  Future<void> acceptCall(String callDocId) async {
    await db
        .collection("calls")
        .doc(callDocId)
        .update({"status": "answered", "acceptedTime": FieldValue.serverTimestamp()})
        .then((value) async {
        })
        .catchError((error) {});
  }

  void onSignOut(){
    userModel = null;
    teacherModel = null;
    currentScreenIndex = 0 ;
    emit(NotificationsRefresh());
  }
}
