import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mehrab/core/config/routes/extension.dart';

import '../utilities/resources/assets.dart';
import 'delete_waiting_indicator.dart';

class WaitingIndicator extends StatelessWidget {
  final double? size;

  const WaitingIndicator({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.waitingIndicator,
        height: size ?? 6.hR,
        fit: BoxFit.fill,
      ),
    );
  }
}

class WaitingTextFormIndicator extends StatelessWidget {
  const WaitingTextFormIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(context.invertedColor, BlendMode.modulate),
      child: Lottie.asset(AppAssets.waitingDots, width: 80, height: 40),
    );
  }
}

class WaitingDonLoadingReport extends StatelessWidget {
  const WaitingDonLoadingReport({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: LinearWaitingIndicator(),
      );
    }
    return const SizedBox.shrink();
  }
}
