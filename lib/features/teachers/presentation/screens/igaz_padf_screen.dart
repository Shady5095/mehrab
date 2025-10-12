import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:mehrab/core/utilities/resources/colors.dart';
import 'package:mehrab/core/widgets/buttons_widget.dart';
import 'package:mehrab/core/widgets/list_empty_widget.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:mehrab/features/teachers/presentation/manager/add_teacher_cubit/add_teacher_cubit.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class IgazPdfScreen extends StatelessWidget {
  const IgazPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> args =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;
    BuildContext oldContext = args[0];
    return BlocProvider.value(
      value: AddTeacherCubit.get(oldContext),
      child: BlocBuilder<AddTeacherCubit, AddTeacherState>(
        builder: (context, state) {
          final cubit = AddTeacherCubit.get(context);
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 20,
                      top: 20,
                    ),
                    child: MyAppBar(
                      flex: 5,
                      title: " صورة الإجازة",
                      isTextTranslate: false,
                      actionIcon: Row(
                        children: [
                          if(cubit.igazPdfUrl != null || cubit.igazPdfFile != null)
                          TextButton(
                            onPressed: () {
                              cubit.clearIgazPdf();
                            },
                            child: Text(
                              "حذف",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                                fontFamily: "Cairo"
                              )
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text(
                                "تم",
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.myAppColor,
                                    fontFamily: "Cairo"
                                )
                            ),
                          ),
                        ],
                      ) ,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child:
                      cubit.igazPdfUrl != null ? SfPdfViewer.network(
                        cubit.igazPdfUrl!,
                        interactionMode: PdfInteractionMode.pan,
                        scrollDirection: PdfScrollDirection.vertical,
                        enableDoubleTapZooming: true,
                      ): (cubit.igazPdfFile == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: ListEmptyWidget(
                                    icon: "assets/images/pdf-upload.png",
                                    title: "لا توجد صورة",
                                    description: "يرجى إضافة صورة الإجازة بصيغة PDF",
                                    isTextTranslate: false,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ButtonWidget(
                                  onPressed: () {
                                    cubit.pickIgazPdfFile();
                                  },
                                  label: "أضف صورة الإجازة",
                                  width: 50.wR,
                                  height: 38,
                                ),
                              ],
                            )
                            : SfPdfViewer.file(
                              cubit.igazPdfFile!,
                              interactionMode: PdfInteractionMode.pan,
                              scrollDirection: PdfScrollDirection.vertical,
                              enableDoubleTapZooming: true,
                            )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
