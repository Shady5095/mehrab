import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/widgets/my_alert_dialog.dart';
import 'package:mehrab/features/home/presentation/manager/home_cubit/home_cubit.dart';
import 'package:mehrab/features/teacher_call/data/models/call_model.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../../../core/utilities/functions/toast.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';

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
  Timer? _countdownTimer;
  int _countdown = 10;
  bool _isEnabled = false;

  Future<void> playSound() async {
    _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/ringtone.mp3'));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    //playSound();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    //stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocProvider.value(
        value: widget.cubit,
        child: BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            if (state is ErrorWhileCreateMeeting) {
              myToast(
                msg: state.error,
                state: ToastStates.error,
                toastLength: Toast.LENGTH_LONG,
              );
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
                      AppStrings.incomingCall.tr(context),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                Text(
                  AppStrings.wantsToJoinSession.tr(context),
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
                if (!_isEnabled)
                SizedBox(height: 10.sp),
                if (!_isEnabled)
                Text(
                  textAlign: TextAlign.center,
                  "برجاء انتظار المكالمه التي ستأتي من الاشعارات والرد منها, اذا لم تأتي المكالمه ف الاشعارات خلال 10 ثواني قم بالرد من هنا",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline Button
                    Opacity(
                      opacity: _isEnabled ? 1.0 : 0.4,
                      child: InkWell(
                        onTap: _isEnabled
                            ? () {
                          widget.cubit.declineCall(widget.model.callId);
                          widget.cubit.isDialogShowing = false;
                          context.pop();
                        }
                            : null,
                        borderRadius: BorderRadius.circular(25.sp),
                        child: CircleAvatar(
                          radius: 27.sp,
                          backgroundColor: _isEnabled ? Colors.red : Colors.red.withValues(alpha: 0.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              if (!_isEnabled)
                                Text(
                                  '$_countdown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Accept Button
                    Opacity(
                      opacity: _isEnabled ? 1.0 : 0.4,
                      child: InkWell(
                        onTap: _isEnabled ? () async => onTapAccept() : null,
                        borderRadius: BorderRadius.circular(25.sp),
                        child: CircleAvatar(
                          radius: 27.sp,
                          backgroundColor: _isEnabled ? Colors.green : Colors.green.withValues(alpha: 0.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              if (!_isEnabled)
                                Text(
                                  '$_countdown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
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
    // stopSound();
    context.pop();
    widget.cubit.isDialogShowing = false;
    widget.cubit.acceptCall(widget.model.callId);
    context.navigateTo(pageName: AppRoutes.teacherCallScreen, arguments: [widget.model]);
  }
}