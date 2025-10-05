import 'package:flutter/material.dart';
import '../widgets/teacher_reviews_screen_body.dart';

class TeacherReviewsScreen extends StatelessWidget {
  const TeacherReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      body: TeacherReviewsScreenBody(),
    );
  }
}
