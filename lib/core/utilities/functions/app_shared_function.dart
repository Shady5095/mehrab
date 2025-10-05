import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../widgets/app_animation.dart';
import '../../widgets/waiting_indicator.dart';

Widget buildListOrEmptyList({
  required List list,
  required Widget Function() listItem,
  required Widget Function() emptyListItem,
}) {
  if (list.isEmpty) {
    return emptyListItem();
  } else {
    return listItem();
  }
}

Widget buildListItemOrWaitingIndicator<T>({
  required int index,
  required List<T> list,
  required Widget Function(T) listItem,
  required bool isFinish,
}) {
  if (index < list.length) {
    return ListItemAnimation(index: index, child: listItem(list[index]));
  } else {
    if (isFinish) {
      return const SizedBox.shrink();
    } else {
      return const WaitingIndicator();
    }
  }
}


Widget listenToListScroll({
  required Widget child,
  required bool isFinish,
  required void Function(ScrollNotification scrollNotification) paginationLogic,
}) => NotificationListener(
  onNotification: (scrollNotification) {
    if (scrollNotification is ScrollEndNotification && !isFinish) {
      paginationLogic(scrollNotification);
    }
    return true;
  },
  child: child,
);
// make this item reusable for all list
Widget buildAdaptiveListItemOrViewShimmerItem({
  required int index,
  required List list,
  required Widget waitingItem,
  required Widget Function(int index) listItem,
  required bool isFinish,
}) {
  if (index < list.length) {
    return listItem(index);
  } else {
    if (isFinish) {
      return const SizedBox.shrink();
    }
    return waitingItem;
  }
}

Widget buildItemOrViewWaitingItem<T>({
  required int index,
  required List list,
  required Widget waitingItem,
  required Widget Function(T) listItem,
  required bool isFinish,
}) {
  if (index < list.length) {
    return listItem(list[index]);
  } else {
    if (isFinish) {
      return const SizedBox.shrink();
    }
    return waitingItem;
  }
}

Widget buildItemOrViewWaitingItemWithAnimation<T>({
  required int index,
  required List list,
  required Widget waitingItem,
  required Widget Function(T) listItem,
  required bool isFinish,
}) {
  if (index < list.length) {
    return ListItemAnimation(index: index, child: listItem(list[index]));
  } else {
    if (isFinish) {
      return const SizedBox.shrink();
    }
    return waitingItem;
  }
}

Widget buildAdaptiveListItemOrViewShimmerItemWithAnimation({
  required int index,
  required List list,
  required Widget waitingItem,
  required Widget Function(int index) listItem,
  required bool isFinish,
}) {
  if (index < list.length) {
    return ListItemAnimation(index: index, child: listItem(index));
  } else {
    if (isFinish) {
      return const SizedBox.shrink();
    }
    return waitingItem;
  }
}
