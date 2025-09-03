import 'package:flutter/material.dart';
import '../widgets/teachers_screen_body.dart';

class TeachersScreen extends StatelessWidget { 
  const TeachersScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      body: TeachersScreenBody(), 
    );
  }
}
