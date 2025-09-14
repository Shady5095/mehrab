import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mehrab/core/config/routes/extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utilities/resources/strings.dart';
import '../../../../core/widgets/my_alert_dialog.dart';

class ContactUsDialog extends StatelessWidget {
  const ContactUsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MyAlertDialog(
      width: 75.wR,
      actions: [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.contactUs.tr(context),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.hosniAbuOmar.tr(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    "+905308187582",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  openWhatsapp(
                    phoneNumber: "+905308187582",
                    text: 'مرحبا ياشيخ حسني, اريد التواصل معك بخصوص...',
                  );
                },
                icon: Icon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                  size: 25.sp,
                ),
                iconSize: 25.sp,
              ),
              IconButton(
                onPressed: () {
                  callDial("+905308187582");
                },
                icon: Icon(
                  Icons.call,
                  color: Colors.blue,
                  size: 25.sp,
                ),
                iconSize: 25.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

}
void openWhatsapp({
  required String phoneNumber,
  required String text,
}) async {
  var contact = phoneNumber;
  var androidUrl = "whatsapp://send?phone=$contact&text=$text";
  var iosUrl = "https://wa.me/$contact?text=${Uri.parse(text)}";

  try {
    if (Platform.isIOS) {
      await launchUrl(Uri.parse(iosUrl));
    } else {
      await launchUrl(Uri.parse(androidUrl));
    }
  } on Exception {
    null;
  }
}
void callDial(String phoneNumber) async {
  Uri uri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(uri);
}