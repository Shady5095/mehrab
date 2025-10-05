import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mehrab/core/utilities/resources/assets.dart';
import 'package:mehrab/core/utilities/resources/strings.dart';
import 'package:mehrab/core/widgets/app_animation.dart';
import 'package:mehrab/core/widgets/server_error_widget.dart';
import '../../../../core/utilities/resources/constants.dart';
import '../../../../core/utilities/services/cache_service.dart';
import '../../../../core/widgets/list_empty_widget.dart';
import '../../data/models/notification_model.dart';
import 'notification_item.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: getCurrentQuery,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ServerErrorWidget(errorMessage: snapshot.error.toString()),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ListEmptyWidget(
            icon: AppAssets.notification,
            title: AppStrings.noNotificationsTitle,
            description: AppStrings.noNotificationsSubTitle,
          );
        }

        final notifications =
            snapshot.data!.docs
                .map(
                  (doc) => NotificationModel.fromJson(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();
        CacheService.setData(key: "notificationCount", value: notifications.length);
        return AnimationLimiter(
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListItemAnimation(
                index: index,
                child: NotificationItem(model: notification),
              );
            },
          ),
        );
      },
    );
  }
  Stream<QuerySnapshot<Object?>> get getCurrentQuery {
    final adminQuery = FirebaseFirestore.instance.collection('notifications')
        .orderBy("timestamp", descending: true).snapshots();
    final studentsQuery =  FirebaseFirestore.instance
        .collection('notifications')
        .where('role', whereIn: ['all', 'students',myUid])
        .orderBy("timestamp", descending: true)
        .snapshots();
    final teachersQuery =  FirebaseFirestore.instance
        .collection('notifications')
        .where('role', whereIn: ['all', 'teachers'])
        .orderBy("timestamp", descending: true)
        .snapshots();
    if(AppConstants.isAdmin){
      return adminQuery;
    }else if(AppConstants.isStudent) {
      return studentsQuery;
    }else{
      return teachersQuery;
    }
  }
}
