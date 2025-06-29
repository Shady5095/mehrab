import 'package:flutter/material.dart';
import 'package:mehrab/core/config/routes/extension.dart';

Future<T?> showBottomSheetWithDraggable<T>({
  required BuildContext context,
  required Widget child,
  double initialChildSize = 0.5,
  double minChildSize = 0.3,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
  Color barrierColor = Colors.black54,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: barrierColor,
    backgroundColor: Colors.transparent,
    builder: (_) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        context.pop();
      },
      child: GestureDetector(


        onTap: (){

        },
        child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,

          builder: (ctx, scrollCtrl) {
            return Container(
              decoration:  BoxDecoration(
                color: ctx.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                child: child,
              ),
            );
          },
        ),
      ),
    ),
  );
}