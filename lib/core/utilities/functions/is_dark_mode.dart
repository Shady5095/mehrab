import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

bool isDarkMode(BuildContext context) {
  return context.backgroundColor.toARGB32() != 0xFFFFFFFF;
}
