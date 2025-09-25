import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/format_date_and_time.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/list_empty_widget.dart';
import 'package:mehrab/features/sessions/presentation/widgets/session_item_for_students.dart';
import 'package:mehrab/features/sessions/presentation/widgets/session_item_for_teachers.dart';

import '../../../../core/utilities/resources/constants.dart';
import '../../../teacher_call/data/models/call_model.dart';

class SessionsList extends StatelessWidget {
  const SessionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: getSessionsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final calls = snapshot.data!.docs;
          if (calls.isEmpty) {
            return ListEmptyWidget(
              icon: "assets/images/session.png",
              title: AppStrings.noSessionsTitle,
              description: AppStrings.noSessionsDescription,
            );
          }

          Map<String, List<CallModel>> groupedCalls = {};
          DateTime now = DateTime.now(); // Uses device's local time zone
          DateTime yesterday = now.subtract(Duration(days: 1));

          for (var doc in calls) {
            CallModel call = CallModel.fromJson(
              doc.data() as Map<String, dynamic>,
            );
            DateTime callDate = call.timestamp.toDate();
            String dateKey = _getDateKey(callDate, now, yesterday, context);

            if (!groupedCalls.containsKey(dateKey)) {
              groupedCalls[dateKey] = [];
            }
            groupedCalls[dateKey]!.add(call);
          }
          return CustomScrollView(
            slivers:
                groupedCalls.entries.map((entry) {
                  String dateKey = entry.key;
                  List<CallModel> dailyCalls = entry.value;
                  return SliverStickyHeader.builder(
                    builder:
                        (context, state) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Container()),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              width: 40.wR,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(230, 230, 230, 1.0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dateKey,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        if(AppConstants.isTeacher){
                          return SessionItemForTeachers(model: dailyCalls[index]);
                        }else{
                          return SessionItemForStudents(model: dailyCalls[index]);
                        }
                      },
                      separatorBuilder: (context, index) => SizedBox(),
                      itemCount: dailyCalls.length,
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  String _getDateKey(
    DateTime callDate,
    DateTime now,
    DateTime yesterday,
    BuildContext context,
  ) {
    if (isSameDay(callDate, now)) {
      return AppStrings.today.tr(context);
    } else if (isSameDay(callDate, yesterday)) {
      return AppStrings.yesterday.tr(context);
    } else {
      return formatDate(context, Timestamp.fromDate(callDate));
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Stream<QuerySnapshot<Object?>> getSessionsStream() {
    if (AppConstants.isTeacher) {
      return FirebaseFirestore.instance
          .collection('calls')
          .where('teacherUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'ended')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('calls')
          .where('studentUid', isEqualTo: myUid)
          .where('status', whereIn: ['ended', 'answered'])
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }
}
