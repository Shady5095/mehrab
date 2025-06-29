import 'package:flutter/material.dart';

import 'background_gradient.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Gradient? gradient;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar,
    this.floatingActionButtonLocation,
    this.gradient,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? backgroundGradient(context),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? false,
    );
  }
}
