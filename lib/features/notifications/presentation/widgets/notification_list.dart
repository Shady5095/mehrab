import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../../data/models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final List<NotificationModel> _notifications = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      final query = _getBaseQuery().limit(_pageSize);
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _notifications.addAll(
          snapshot.docs.map((doc) =>
              NotificationModel.fromJson(doc.data())),
        );
        _hasMore = snapshot.docs.length == _pageSize;
      } else {
        _hasMore = false;
      }

      CacheService.setData(key: "notificationCount", value: _notifications.length);
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = _getBaseQuery()
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize);
      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _notifications.addAll(
          snapshot.docs.map((doc) =>
              NotificationModel.fromJson(doc.data())),
        );
        _hasMore = snapshot.docs.length == _pageSize;
        CacheService.setData(key: "notificationCount", value: _notifications.length);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('Error loading more data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Query<Map<String, dynamic>> _getBaseQuery() {
    final collection = FirebaseFirestore.instance.collection('notifications');

    if (AppConstants.isAdmin) {
      return collection.orderBy("timestamp", descending: true);
    } else if (AppConstants.isStudent) {
      return collection
          .where('role', whereIn: ['all', 'students', myUid])
          .orderBy("timestamp", descending: true);
    } else {
      return collection
          .where('role', whereIn: ['all', 'teachers'])
          .orderBy("timestamp", descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return ListEmptyWidget(
        icon: AppAssets.notification,
        title: AppStrings.noNotificationsTitle,
        description: AppStrings.noNotificationsSubTitle,
      );
    }

    return AnimationLimiter(
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: _notifications.length + (_hasMore && _isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= _notifications.length) {
            return const NotificationShimmerItem();
          }

          final notification = _notifications[index];
          return ListItemAnimation(
            index: index,
            child: NotificationItem(model: notification),
          );
        },
      ),
    );
  }
}