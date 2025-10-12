import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/features/teachers/data/models/teachers_model.dart';

import '../../../../core/utilities/functions/format_date_and_time.dart';
import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../../../sessions/presentation/widgets/session_item_for_teachers.dart';
import '../../../teacher_call/data/models/call_model.dart';

class TeacherSessionsInProfileView extends StatefulWidget {
  final TeacherModel model;
  const TeacherSessionsInProfileView({super.key, required this.model});

  @override
  State<TeacherSessionsInProfileView> createState() => _TeacherSessionsInProfileViewState();
}

class _TeacherSessionsInProfileViewState extends State<TeacherSessionsInProfileView> {
  final int _pageSize = 10 ;
  final ScrollController _scrollController = ScrollController();

  final List<CallModel> _calls = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCalls();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchCalls(); // تحميل الصفحة التالية
      }
    });
  }

  Future<void> _fetchCalls() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('calls')
        .where('teacherUid', isEqualTo: widget.model.uid)
        .where('status', isEqualTo: 'ended')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      final newCalls = snapshot.docs.map((doc) => CallModel.fromJson(doc.data() as Map<String, dynamic>)).toList();
      setState(() {
        _calls.addAll(newCalls);
      });
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_calls.isEmpty && !_isLoading) {
      return ListEmptyWidget(
        icon: "assets/images/session.png",
        title: AppStrings.noSessionsTitle,
        description: AppStrings.noSessionsDescription,
      );
    }

    Map<String, List<CallModel>> groupedCalls = {};
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    for (var call in _calls) {
      DateTime callDate = call.timestamp.toDate();
      String dateKey = _getDateKey(callDate, now, yesterday, context);

      if (!groupedCalls.containsKey(dateKey)) {
        groupedCalls[dateKey] = [];
      }
      groupedCalls[dateKey]!.add(call);
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        ...groupedCalls.entries.map((entry) {
          String dateKey = entry.key;
          List<CallModel> dailyCalls = entry.value;
          return SliverStickyHeader.builder(
            builder: (context, state) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: 40.wR,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
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
                return SessionItemForTeachers(model: dailyCalls[index]);
              },
              separatorBuilder: (context, index) => SizedBox(),
              itemCount: dailyCalls.length,
            ),
          );
        }),
        if (_isLoading)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  String _getDateKey(DateTime callDate, DateTime now, DateTime yesterday, BuildContext context) {
    if (isSameDay(callDate, now)) {
      return AppStrings.today.tr(context);
    } else if (isSameDay(callDate, yesterday)) {
      return AppStrings.yesterday.tr(context);
    } else {
      return formatDate(context, Timestamp.fromDate(callDate));
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}
