import 'dart:io';

import 'package:flutter/cupertino.dart';
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
      makeIosAndAndroidSameDialog: true,
      width: 65.wR,
      actions: [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5bafa5),
                  Color(0xFF3a848a),
                  Color(0xff2d787e),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.question_square,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 10),
          Text(
            AppStrings.contactUs.tr(context),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppStrings.inAppProblem.tr(context),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.hosniAbuOmar.tr(context),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 14.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              "+905308187582",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Contact Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactButton(
                      icon: FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      label: 'واتساب',
                      onTap: () {
                        openWhatsapp(
                          phoneNumber: "+905343284249",
                          text: 'مرحبا ياشيخ حسني, اريد التواصل معك بخصوص...',
                        );
                      },
                    ),
                    SizedBox(width: 5),
                    _buildContactButton(
                      icon: FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      label: 'واتساب',
                      onTap: () {
                        openWhatsapp(
                          phoneNumber: "+905308187582",
                          text: 'مرحبا ياشيخ حسني, اريد التواصل معك بخصوص...',
                        );
                      },
                    ),
                    SizedBox(width: 5),
                    _buildContactButton(
                      icon: Icons.phone,
                      color: Color(0xFF2196F3),
                      label: 'اتصال',
                      onTap: () {
                        callDial("+905308187582");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10),
          Text(
            AppStrings.followUs.tr(context),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: FontAwesomeIcons.facebook,
                color: Color(0xFF1877F2),
                onTap: () {
                  openSocialMedia('https://www.facebook.com/share/172uzfubW7/?mibextid=wwXIfr');
                },
              ),
              SizedBox(width: 12),
              _buildSocialButton(
                icon: FontAwesomeIcons.tiktok,
                color: Colors.black,
                onTap: () {
                  openSocialMedia('http://www.tiktok.com/@mehrab.alquran');
                },
              ),
              SizedBox(width: 12),
              _buildSocialButton(
                icon: FontAwesomeIcons.youtube,
                color: Colors.red,
                onTap: () {
                  openSocialMedia('https://www.youtube.com/@mihrab-alquran');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22.sp,
        ),
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
  var iosUrl = "https://wa.me/$contact?text=${Uri.encodeComponent(text)}";

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

void openSocialMedia(String url) async {
  try {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } on Exception {
    null;
  }
}