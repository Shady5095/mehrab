import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import '../widgets/sessions_screen_body.dart';

class SessionsScreen extends StatelessWidget { 
  const SessionsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.offlineWhite,
      body: SessionsScreenBody(),
    );
  }
}
