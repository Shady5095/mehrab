import 'package:mehrab/core/utilities/functions/toast.dart';
import 'package:url_launcher/url_launcher.dart';

void appLaunchUrl(String link) async {
  final Uri uri = Uri.parse(link);
  !await launchUrl(uri).catchError((error) {
    myToast(msg: 'Url not valid', state: ToastStates.error);
    return false;
  });
}

void launchHtmlUrl(String? url, Map<String, String> attributes, dynamic element) {
  appLaunchUrl(url ?? '');
}
