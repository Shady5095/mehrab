import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

bool isDarkMode(BuildContext context) {
  if (context.backgroundColor.value.toString() == '4294967295') {
    return false;
  } else {
    return true;
  }
}
