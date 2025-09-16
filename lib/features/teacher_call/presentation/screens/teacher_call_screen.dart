import 'package:flutter/material.dart';
import '../widgets/teacher_call_screen_body.dart';

class TeacherCallScreen extends StatelessWidget { 
  const TeacherCallScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      body: TeacherCallScreenBody(), 
    );
  }
}
