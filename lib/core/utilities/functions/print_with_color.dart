import 'package:flutter/foundation.dart';

void printWithColor(dynamic text) {
  if (kDebugMode) {
    print('\x1B[33m$text\x1B[0m');
  }
}
