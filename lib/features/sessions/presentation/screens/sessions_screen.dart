import 'package:flutter/material.dart';
import '../widgets/sessions_screen_body.dart';

class SessionsScreen extends StatelessWidget { 
  const SessionsScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return const Scaffold( 
      body: SessionsScreenBody(), 
    );
  }
}
