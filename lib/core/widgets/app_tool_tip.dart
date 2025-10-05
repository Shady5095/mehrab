import 'package:flutter/material.dart';

import '../utilities/resources/styles.dart';

class TooltipOnTap extends StatefulWidget {
  const TooltipOnTap({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<TooltipOnTap> createState() => _TooltipOnTapState();
}

class _TooltipOnTapState extends State<TooltipOnTap> {
  final _key = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _key.currentState?.ensureTooltipVisible();
      },
      child: Tooltip(
        showDuration: const Duration(seconds: 2),
        exitDuration: const Duration(seconds: 1),
        waitDuration: const Duration(milliseconds: 500),

        margin: const EdgeInsets.symmetric(horizontal: 20),
        key: _key,
        textAlign: TextAlign.center,
        message: widget.message,
        child: widget.child,
      ),
    );
  }
}

class CustomTooltip extends StatefulWidget {
  final String text;
  final Widget child;
  final TextStyle style;

  const CustomTooltip({
    super.key,
    required this.text,
    required this.child,
    required this.style,
  });

  @override
  State<StatefulWidget> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animation duration
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return; // Prevent duplicate tooltips

    final renderBox = context.findRenderObject() as RenderBox;
    final widgetSize = renderBox.size;
    final widgetPosition = renderBox.localToGlobal(Offset.zero);

    if (hasTextOverflow(widget.text, widget.style, widgetSize.width - 30)) {
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            left: widgetPosition.dx / 2,
            top: widgetPosition.dy + widgetSize.height, // Below the widget
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _animationController,
                child: ScaleTransition(
                  scale: _animationController,
                  child: ClipPath(
                    clipper: TooltipClipper(),
                    child: Container(
                      width: widgetSize.width,
                      color: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 12,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.text,
                        style: AppStyle.textStyle14White.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      Overlay.of(context).insert(_overlayEntry!);

      // Start the show animation
      _animationController.forward();

      // Automatically remove the tooltip after 2 seconds with hide animation
      Future.delayed(const Duration(seconds: 2), _hideTooltip);
    }
  }

  void _hideTooltip() async {
    if (_overlayEntry == null) return;
    // Start the hide animation
    await _animationController.reverse();
    // Remove the overlay
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _showTooltip, child: widget.child);
  }
}

class TooltipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const arrowHeight = 8.0;
    const arrowWidth = 16.0;
    const borderRadius = 10.0;

    // Top-left corner
    path.moveTo(borderRadius, arrowHeight);
    path.arcToPoint(
      const Offset(0, arrowHeight + borderRadius),
      radius: const Radius.circular(borderRadius),
      clockwise: false,
    );

    // Left side
    path.lineTo(0, size.height - borderRadius);
    path.arcToPoint(
      Offset(borderRadius, size.height),
      radius: const Radius.circular(borderRadius),
      clockwise: false,
    );

    // Bottom side
    path.lineTo(size.width - borderRadius, size.height);
    path.arcToPoint(
      Offset(size.width, size.height - borderRadius),
      radius: const Radius.circular(borderRadius),
      clockwise: false,
    );

    // Right side
    path.lineTo(size.width, arrowHeight + borderRadius);
    path.arcToPoint(
      Offset(size.width - borderRadius, arrowHeight),
      radius: const Radius.circular(borderRadius),
      clockwise: false,
    );

    // Top side (arrow in the center)
    path.lineTo(size.width / 2 + arrowWidth / 2, arrowHeight);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width / 2 - arrowWidth / 2, arrowHeight);

    path.lineTo(borderRadius, arrowHeight); // Connect to the start point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

bool hasTextOverflow(String text, TextStyle style, double maxWidth) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1, // Set to 1 for single-line text
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  return textPainter.didExceedMaxLines || textPainter.width > maxWidth;
}

class AppToolTip extends StatelessWidget {
  const AppToolTip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      textAlign: TextAlign.center,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: child,
    );
  }
}
