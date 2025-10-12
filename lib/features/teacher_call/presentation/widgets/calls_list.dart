import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/functions/format_date_and_time.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/list_empty_widget.dart';

import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../data/models/call_model.dart';
import 'call_item.dart';

class CallsList extends StatefulWidget {
  const CallsList({super.key});

  @override
  State<CallsList> createState() => _CallsListState();
}

class _CallsListState extends State<CallsList> {
  final int _pageSize = 15; // عدد العناصر في كل صفحة
  final ScrollController _scrollController = ScrollController();

  final List<CallModel> _calls = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCalls();
    _updateMissedCallsCount(); // ✅ استدعاء حساب المكالمات الفائتة مرة واحدة

    // تحميل الصفحة التالية عند الاقتراب من نهاية القائمة
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchCalls();
      }
    });
  }

  /// 🔹 تحميل بيانات المكالمات بصفحات (Pagination)
  Future<void> _fetchCalls() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('calls')
        .where('teacherUid', isEqualTo: myUid)
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;

      final newCalls = snapshot.docs.map((doc) {
        return CallModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      setState(() {
        _calls.addAll(newCalls);
      });
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  /// 🔹 حساب عدد المكالمات الفائتة مرة واحدة فقط (بدون تحميل كل البيانات)
  Future<void> _updateMissedCallsCount() async {
    try {
      final countQuery = FirebaseFirestore.instance
          .collection('calls')
          .where('teacherUid', isEqualTo: myUid)
          .where('status', isEqualTo: 'missed')
          .count();

      final countSnapshot = await countQuery.get();
      int missedCount = countSnapshot.count??0;

      await CacheService.setData(
        key: "missedCallCount",
        value: missedCount,
      );
    } catch (e) {
      debugPrint("Error updating missed call count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_calls.isEmpty && !_isLoading) {
      return Expanded(
        child: ListEmptyWidget(
          icon: "assets/images/phone-call.png",
          title: AppStrings.noCallsTitle,
          description: AppStrings.noCallsDescription,
        ),
      );
    }

    Map<String, List<CallModel>> groupedCalls = {};
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    for (var call in _calls) {
      DateTime callDate = call.timestamp.toDate();
      String dateKey = _getDateKey(callDate, now, yesterday, context);

      groupedCalls.putIfAbsent(dateKey, () => []);
      groupedCalls[dateKey]!.add(call);
    }

    return Expanded(
      child: CustomScrollView(
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
                    width: 40.wR,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(240, 240, 240, 1.0),
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
                  return CallItem(model: dailyCalls[index]);
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: dailyCalls.length,
              ),
            );
          }),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🔹 تحديد عنوان القسم (اليوم / أمس / تاريخ آخر)
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
