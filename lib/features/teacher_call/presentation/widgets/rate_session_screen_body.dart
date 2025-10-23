import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:mehrab/core/utilities/resources/constants.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:mehrab/core/widgets/my_text_field.dart';
import 'package:mehrab/features/teacher_call/presentation/manager/rate_session_cubit/rate_session_cubit.dart';
import 'package:mehrab/features/teacher_call/presentation/widgets/quran_surah_dialog.dart';

import '../../../../core/widgets/my_appbar.dart';
import '../../../../core/widgets/show_date_time_picker.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';

class RateSessionScreenBody extends StatelessWidget {
  const RateSessionScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<RateSessionCubit, RateSessionState>(
        listener: (context, state) {
          if (state is RateSessionError) {
            myToast(msg: state.message, state: ToastStates.error);
          } else if (state is RateSessionSuccess) {
            myToast(
              msg: AppStrings.sessionDetailsAddedSuccessfully.tr(context),
              state: ToastStates.success,
            );
            context.pop(result: true);
          }
        },
        builder: (context, state) {
          final cubit = RateSessionCubit.instance(context);
          return Form(
            key: cubit.formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        MyAppBar(
                          title:
                              cubit.isEditMode
                                  ? AppStrings.editSessionDetails
                                  : AppStrings.sessionDetailsAndStudentRate,
                          titleTextStyle: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        BuildUserItemPhoto(
                          imageUrl: cubit.callModel.studentPhoto,
                          radius: 37.sp,
                          imageColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cubit.callModel.studentName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        RatingBar.builder(
                          minRating: 0,
                          unratedColor: Colors.black.withValues(alpha: 0.2),
                          itemSize: 35.sp,
                          initialRating: cubit.rating,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 0.0,
                          ),
                          itemBuilder:
                              (context, _) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            cubit.updateRating(rating);
                          },
                        ),
                        if (cubit.isEditMode && AppConstants.isAdmin) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextField(
                                  controller: cubit.startTimeController,
                                  readOnly: true,
                                  enabled: AppConstants.isAdmin,
                                  onTap: () {
                                    showMyDateTimePicker(
                                      context,
                                      firstTime: DateTime(2009),
                                      initialDate:
                                          cubit.startTime?.toDate() ??
                                          DateTime.now(),
                                    ).then((dateTime) {
                                      if (dateTime != null) {
                                        cubit.startTime = Timestamp.fromDate(
                                          dateTime,
                                        );
                                        cubit.endTime = null;
                                        cubit.endTimeController.text = '';
                                        cubit
                                            .startTimeController
                                            .text = formatDateTimePicker(
                                          context,
                                          dateTime,
                                        );
                                      }
                                    });
                                  },
                                  label: AppStrings.startTime.tr(context),
                                  maxLines: 1,
                                  minLines: 1,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: MyTextField(
                                  controller: cubit.endTimeController,
                                  readOnly: true,
                                  enabled: AppConstants.isAdmin,
                                  onTap: () {
                                    if (cubit.startTime == null) {
                                      myToast(
                                        msg: AppStrings.pleaseSelectStartDateFirst
                                            .tr(context),
                                        state: ToastStates.error,
                                      );
                                      return;
                                    }
                                    showMyDateTimePicker(
                                      context,
                                      firstTime: cubit.startTime!.toDate(),
                                      initialDate:
                                          cubit.endTime?.toDate() ??
                                          DateTime.now(),
                                    ).then((dateTime) {
                                      if (dateTime != null) {
                                        cubit.endTime = Timestamp.fromDate(
                                          dateTime,
                                        );
                                        cubit
                                            .endTimeController
                                            .text = formatDateTimePicker(
                                          context,
                                          dateTime,
                                        );
                                      }
                                    });
                                  },
                                  label: AppStrings.endDate.tr(context),
                                  maxLines: 1,
                                  minLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        MyTextField(
                          controller: cubit.recordController,
                          label: "${AppStrings.record.tr(context)} 1",
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextField(
                                controller: cubit.fromSurahController,
                                label: AppStrings.fromSurah.tr(context),
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => QuranSurahDialog(
                                          onSurahSelected:
                                              (surahName, surahNum) {
                                            cubit.setFromSurah(surahName);
                                              },
                                        ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyTextField(
                                controller: cubit.fromAyahController,
                                label: AppStrings.ayah.tr(context),
                                keyboardType: TextInputType.number,
                                validator: (value){
                                  final fromAyah =
                                      int.tryParse(cubit.fromAyahController.text) ??
                                          0;
                                  if (cubit.getVerseCountBySurahName(cubit.fromSurahController.text) <
                                      fromAyah) {
                                    return   "سورة ${cubit.fromSurahController.text} ${cubit.getVerseCountBySurahName(cubit.fromSurahController.text)} اية فقط " ;

                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextField(
                                controller: cubit.toSurahController,
                                label: AppStrings.toSurah.tr(context),
                                keyboardType: TextInputType.text,
                                readOnly: true,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => QuranSurahDialog(
                                          fromSurah: cubit.fromSurahController.text,
                                      onSurahSelected:
                                          (surahName, surahNum) {
                                        cubit.setToSurah(surahName);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyTextField(
                                controller: cubit.toAyahController,
                                label: AppStrings.ayah.tr(context),
                                keyboardType: TextInputType.number,
                                validator: (value){
                                  final toAyah =
                                      int.tryParse(cubit.toAyahController.text) ??
                                          0;
                                  if (cubit.getVerseCountBySurahName(cubit.toSurahController.text) <
                                      toAyah) {
                                    return   "سورة ${cubit.toSurahController.text} ${cubit.getVerseCountBySurahName(cubit.toSurahController.text)} اية فقط " ;

                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextField(
                                controller: cubit.numberOfFacesController,
                                label: AppStrings.numberOfFaces.tr(context),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyTextField(
                                controller: cubit.wordErrorsController,
                                label: AppStrings.wordErrors.tr(context),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextField(
                                controller: cubit.theHesitationController,
                                label: AppStrings.theHesitation.tr(context),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyTextField(
                                controller: cubit.tajweedErrorsController,
                                label: AppStrings.tajweedErrors.tr(context),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        MyTextField(
                          controller: cubit.commentController,
                          label: AppStrings.comment.tr(context),
                          keyboardType: TextInputType.text,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: ButtonWidget(
                    onPressed: () {
                      if(!cubit.formKey.currentState!.validate()){
                        return;
                      }
                      cubit.updateSession();
                    },
                    label:
                        cubit.isEditMode
                            ? AppStrings.edit.tr(context)
                            : AppStrings.send.tr(context),
                    height: 38,
                    isLoading: state is RateSessionLoading,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
