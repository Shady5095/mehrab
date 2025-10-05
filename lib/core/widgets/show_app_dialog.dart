import 'package:flutter/material.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget content,
  bool barrierDismissible = true,
  Color ? backgroundColor,


  Duration transitionDuration = const Duration(milliseconds: 400),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return AlertDialog(
        backgroundColor: backgroundColor ,
        actionsAlignment: MainAxisAlignment.center,
        insetPadding: const EdgeInsets.all(20),

        content: content,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Slide from the bottom with a fade effect
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final fadeTween = Tween<double>(begin: 0, end: 1);

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

Future<T?> showAnimationToDialog<T>({
  required BuildContext context,
  required Widget dialog,
  bool barrierDismissible = true,
  Duration transitionDuration = const Duration(milliseconds: 400),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) => dialog,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Slide from the bottom with a fade effect
      final slideTween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final fadeTween = Tween<double>(begin: 0, end: 1);

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

// Future<T?> showDraggableModalBottomSheet<T>({
//   required BuildContext context,
//   required Widget content,
// }) {
//   return showModalBottomSheet<T>(
//     context: context,
//     isScrollControlled: true,
//
//     backgroundColor: Colors.transparent,
//     builder:
//         (_) => GestureDetector(
//           onTap: () {
//             Navigator.of(context).pop();
//           },
//           behavior: HitTestBehavior.opaque,
//           child: GestureDetector(
//             onTap: () {
//               // Prevent closing the dialog when tapping inside the content
//             },
//             child: DraggableScrollableSheet(
//               // Define the initial, minimum and maximum sizes as fractions of the parent height
//               initialChildSize: 0.7,
//               minChildSize: 0.5,
//               maxChildSize: 0.9,
//               builder: (BuildContext _, ScrollController scrollController) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: context.backgroundColor,
//
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 10.0,
//                         spreadRadius: 0.5,
//                       ),
//                     ],
//                   ),
//                   // The content of the draggable sheet: a ListView that uses the provided scrollController
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: content,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//   );
// }
