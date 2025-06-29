import 'dart:developer';

import 'package:flutter/material.dart';

class AppRouteObserverService extends RouteObserver<PageRoute<dynamic>> {
  static final AppRouteObserverService _instance =
      AppRouteObserverService._internal();

  factory AppRouteObserverService() => _instance;

  AppRouteObserverService._internal();
}

/// Navigation Listener Widget - Wrap any widget with this
class NavigationListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onNavigateAway;
  final VoidCallback? onNavigateBack;

  const NavigationListener({
    super.key,
    required this.child,
    this.onNavigateAway,
    this.onNavigateBack,
  });

  @override
  State<NavigationListener> createState() => _NavigationListenerState();
}

class _NavigationListenerState extends State<NavigationListener>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppRouteObserverService().subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRouteObserverService().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    // User navigated away from this screen
    widget.onNavigateAway?.call();
    log('🟢 User navigated AWAY from this screen');
  }

  @override
  void didPopNext() {
    // User came back to this screen
    widget.onNavigateBack?.call();
    log('🔴 User came BACK to this screen');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
