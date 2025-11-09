import 'package:url_launcher/url_launcher.dart';

class LoginModel {
  late final String mobileNumber;

  LoginModel({required this.mobileNumber});

  Future<bool> requestOTP() async {
    await Future.delayed(const Duration(seconds: 1));
    return mobileNumber.isNotEmpty;
  }

  Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
}