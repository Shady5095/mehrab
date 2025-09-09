import 'package:flutter/material.dart';

class RamadanWelcomeDialog extends StatelessWidget {
  const RamadanWelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: const Image(
          image: AssetImage('assets/images/ramadanWelcome.jpg'),
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
    );
  }
}
