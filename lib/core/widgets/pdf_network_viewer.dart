import 'package:flutter/material.dart';
import 'package:mehrab/core/widgets/my_appbar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfNetworkViewer extends StatelessWidget {
  final String pdfUrl;
  const PdfNetworkViewer({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 20,
                top: 20,
              ),
              child: MyAppBar(title: ''),
            ),
            Expanded(
              child: SfPdfViewer.network(
                pdfUrl,
                interactionMode: PdfInteractionMode.pan,
                scrollDirection: PdfScrollDirection.vertical,
                enableDoubleTapZooming: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
