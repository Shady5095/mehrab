import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/app_routes.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/services/cache_service.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import '../../../../app/main_app_cubit/main_app_cubit.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/colors.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../../../teachers/presentation/widgets/instructions_for_start_session_dialog.dart';

class IncomingCallDialog extends StatefulWidget {
  final HomeCubit cubit;
  final CallModel model;

  const IncomingCallDialog({
    super.key,
    required this.cubit,
    required this.model,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> {
  final AudioPlayer _player = AudioPlayer();
  bool _isCallAccepted = false;
  DateTime? _acceptTime;
  String? googleMeetLink;

  Future<void> playSound() async {
    _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/ringtone.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  @override
  void initState() {
    playSound();
    getAcceptedTime();
    super.initState();
  }

  void getAcceptedTime() {
    if (widget.model.acceptedTime != null) {
      _isCallAccepted = true;
      _acceptTime = widget.model.acceptedTime!.toDate();
      stopSound();
      setState(() {});
    }
  }

  @override
  void dispose() {
    stopSound();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocProvider.value(
        value: widget.cubit,
        child: BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if(state is ErrorWhileCreateMeeting) {
              myToast(msg: state.error, state: ToastStates.error,toastLength: Toast.LENGTH_LONG);
            }
          },
          child: MyAlertDialog(
            makeIosAndAndroidSameDialog: true,
            actions: [],
            width: 70.wR,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isCallAccepted
                          ? AppStrings.ongoingCall.tr(context)
                          : AppStrings.incomingCall.tr(context),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isCallAccepted)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          Icons.call,
                          color: Colors.green,
                          size: 35.sp,
                        ),
                      )
                    else
                      Lottie.asset(
                        delegates: LottieDelegates(
                          values: [
                            ValueDelegate.color(const [
                              '**',
                            ], value: Colors.green),
                          ],
                        ),
                        "assets/json/ringing2.json",
                        width: 50.sp,
                        height: 50.sp,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
                SizedBox(height: 10.sp),
                BuildUserItemPhoto(
                  imageUrl: widget.model.studentPhoto,
                  radius: 45.sp,
                  imageColor: Colors.white,
                ),
                SizedBox(height: 10.sp),
                Text(
                  widget.model.studentName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isCallAccepted)
                  Text(
                    AppStrings.wantsToJoinSession.tr(context),
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  )
                else
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final duration =
                          widget.model.acceptedTime != null
                              ? DateTime.now().difference(
                                widget.model.acceptedTime!.toDate(),
                              )
                              : _acceptTime != null
                              ? DateTime.now().difference(_acceptTime!)
                              : Duration.zero;
                      return Text(
                        _formatDuration(duration),
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      );
                    },
                  ),
                SizedBox(height: 20.sp),
                if (_isCallAccepted)
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (googleMeetLink != null) {
                              widget.cubit.openMeet(googleMeetLink!).catchError(
                                (error) {
                                  myToast(msg: error.toString(), state: error);
                                },
                              );
                            } else {
                              widget.cubit
                                  .acceptCall(
                                    widget.model.callId,
                                    widget.model.studentName,
                                  )
                                  .then((meetLink) {
                                    googleMeetLink = meetLink;
                                    setState(() {});
                                  })
                                  .catchError((error) {
                                    myToast(
                                      msg: error.toString(),
                                      state: error,
                                    );
                                  });
                            }
                          },
                          child: Text(
                            AppStrings.reJoin.tr(context),
                            style: TextStyle(
                              color: AppColors.myAppColor.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily:
                                  MainAppCubit.instance(
                                    context,
                                  ).setFontFamily(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            widget.cubit
                                .endCall(
                                  widget.model.callId,
                                  widget.model.studentUid,
                                  widget.model.teacherName,
                                )
                                .catchError((error) {
                                  myToast(msg: error.toString(), state: error);
                                });
                            context.pop();
                            context.navigateTo(
                              pageName: AppRoutes.rateSessionScreen,
                              arguments: [widget.model, false],
                            );
                          },
                          child: Text(
                            AppStrings.endCall.tr(context),
                            style: TextStyle(
                              color: AppColors.redColor.withValues(alpha: 0.8),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily:
                                  MainAppCubit.instance(
                                    context,
                                  ).setFontFamily(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 25.sp,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 25.sp,
                          ),
                          onPressed: () {
                            widget.cubit.declineCall(widget.model.callId);
                            context.pop();
                          },
                        ),
                      ),
                      CircleAvatar(
                        radius: 25.sp,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 25.sp,
                          ),
                          onPressed: () async {
                            if (CacheService.getData(
                                  key: "instructionsForStartSession",
                                ) ==
                                true) {
                              onTapAccept();
                              return;
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) =>
                                      InstructionsForStartSessionDialog(),
                            ).then((value) {
                              if (value == true) {
                                CacheService.setData(
                                  key: "instructionsForStartSession",
                                  value: true,
                                );
                                onTapAccept();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTapAccept() {
    stopSound();
    setState(() {
      _isCallAccepted = true;
      _acceptTime = DateTime.now();
    });
    widget.cubit
        .acceptCall(widget.model.callId, widget.model.studentName)
        .then((meetLink) {
          googleMeetLink = meetLink;
          setState(() {});
        })
        .catchError((error) {
          myToast(msg: error.toString(), state: error);
        });
  }
}
