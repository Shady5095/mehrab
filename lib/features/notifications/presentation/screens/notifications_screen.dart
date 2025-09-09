import 'package:flutter/material.dart';
import '../widgets/notifications_screen_body.dart';

class NotificationsScreen extends StatelessWidget { 
  const NotificationsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      body: NotificationsScreenBody(), 
    );
  }
}
