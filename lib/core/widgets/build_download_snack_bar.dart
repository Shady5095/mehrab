import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class BuildDownloadSnackBar extends StatelessWidget {
  const BuildDownloadSnackBar({
    super.key,
    required StreamController<int> progressController,
  }) : _progressController = progressController;

  final StreamController<int> _progressController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _progressController.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: snapshot.data / 100.floorToDouble(),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 20),
              Text('${snapshot.data} / 100%'),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

bool isShowDownloadSnackBar(int value) {
  if (Platform.isAndroid) {
    if (value == 0) {
      return true;
    }
    return false;
  } else {
    if (value == 1) {
      return true;
    }
    return false;
  }
}
