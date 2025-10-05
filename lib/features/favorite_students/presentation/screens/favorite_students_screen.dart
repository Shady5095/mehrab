import 'package:flutter/material.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import '../widgets/favorite_students_screen_body.dart';

class FavoriteStudentsScreen extends StatelessWidget { 
  const FavoriteStudentsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.offlineWhite,
      body: FavoriteStudentsScreenBody(), 
    );
  }
}
