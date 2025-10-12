import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/app/app_locale/app_locale.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utilities/functions/format_date_and_time.dart';
import '../../../../core/utilities/functions/format_duration.dart';
import '../../../students/presentation/widgets/build_user_item_photo.dart';
import '../../../teacher_call/data/models/call_model.dart';

class SessionItemForStudents extends StatefulWidget {
  final CallModel model;

  const SessionItemForStudents({super.key, required this.model});

  @override
  State<SessionItemForStudents> createState() => _SessionItemForStudentsState();
}

class _SessionItemForStudentsState extends State<SessionItemForStudents> {
  ExpansibleController controller = ExpansibleController();
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: [
          ExpansionTile(
            onExpansionChanged: (bool expanded) {
              isExpanded = expanded;
              setState(() {});
            },
            controller: controller,
            showTrailingIcon: false,
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            tilePadding: EdgeInsets.only(left: 10, right: 10, top: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Column(
              children: [
                Row(
                  children: [
                    BuildUserItemPhoto(
                      imageUrl: widget.model.teacherPhoto,
                      radius: 25.sp,
                      imageColor: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.model.teacherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          RatingBar.builder(
                            minRating: 0,
                            unratedColor: Colors.black.withValues(alpha: 0.2),
                            itemSize: 20.sp,
                            initialRating:
                                widget.model.rating?.toDouble() ?? 0.0,
                            ignoreGestures: true,
                            itemPadding: const EdgeInsets.symmetric(
                              horizontal: 0.0,
                            ),
                            itemBuilder:
                                (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {},
                          ),
                        ],
                      ),
                    ),
                    if(widget.model.status == "answered")
                    Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 5),
                            Text(
                              AppStrings.answered.tr(context),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.myAppColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Lottie.asset(
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(const [
                                    '**',
                                  ], value: AppColors.myAppColor),
                                ],
                              ),
                              "assets/json/ringing2.json",
                              width: 25.sp,
                              height: 25.sp,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ButtonWidget(
                          onPressed: () {
                            openMeet(widget.model.meetingLink??'');
                          },
                          label: AppStrings.reJoin.tr(context),
                          height: 25,
                          width: 25.wR,
                          labelFontSize: 11.sp,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          AppStrings.startTime.tr(context),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formatTime(context, widget.model.timestamp),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      children: [
                        Text(
                          AppStrings.endTime.tr(context),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formatTime(context, widget.model.endedTime),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Column(
                      children: [
                        Text(
                          AppStrings.duration.tr(context),
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 5),
                        Text(
                          getDurationString(
                            widget.model.timestamp,
                            widget.model.endedTime,
                            isArabic(context),
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            childrenPadding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            children: [
              Row(
                children: [
                  Text(
                    "${AppStrings.record.tr(context)} 1 : ",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    widget.model.record ?? '---',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${AppStrings.fromSurah.tr(context)} : ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.model.fromSurah ?? '---',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.myAppColor,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              "  (${AppStrings.ayah.tr(context)} : ${widget.model.fromAyah != null ? widget.model.fromAyah.toString() : '---'})",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.myAppColor,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${AppStrings.toSurah.tr(context)} : ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.model.toSurah ?? '---',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.myAppColor,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              "  (${AppStrings.ayah.tr(context)} : ${widget.model.toAyah != null ? widget.model.toAyah.toString() : '---'})",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.myAppColor,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "${AppStrings.numberOfFaces.tr(context)} : ",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              widget.model.numberOfFaces ?? '---',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "${AppStrings.wordErrors.tr(context)} : ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.model.wordErrors ?? '---',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "${AppStrings.theHesitation.tr(context)} : ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.model.theHesitation ?? '---',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "${AppStrings.tajweedErrors.tr(context)} : ",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          widget.model.tajweedErrors ?? '---',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    "${AppStrings.comment.tr(context)} : ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.model.comment ?? '-------------',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: () {
              if (controller.isExpanded) {
                controller.collapse();
                isExpanded = false;
              } else {
                controller.expand();
                isExpanded = true;
              }
              setState(() {});
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded
                      ? AppStrings.seeLess.tr(context)
                      : AppStrings.seeMore.tr(context),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.myAppColor,
                    fontWeight: FontWeight.w600,
                    //decoration: TextDecoration.underline
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.myAppColor,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> openMeet(String url) async {
    final Uri meetUrl = Uri.parse(url);
    if (await canLaunchUrl(meetUrl)) {
      await launchUrl(meetUrl, mode: LaunchMode.externalApplication);
    }
  }
}
