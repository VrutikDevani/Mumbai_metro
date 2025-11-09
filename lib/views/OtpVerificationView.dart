import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'HomeServiceView.dart';

class OtpVerificationView extends StatefulWidget {
  final String mobileNumber; // pass mobile number here

  const OtpVerificationView({super.key, required this.mobileNumber});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());

  int _secondsRemaining = 30;
  Timer? _timer;

  static const Color darkBlue = Color(0xFF03669d);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getOtp() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp(String otp) async {
    final url = Uri.parse(
        "http://192.168.1.100:8000/api/customers/${widget.mobileNumber}/otpverify?otp=$otp");

    try {
      final response = await http.put(url);

      if (response.statusCode == 200) {
        // ✅ OTP Success
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeServiceView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _resendOtp() async {
    final url = Uri.parse(
        "http://192.168.1.100:8000/api/customers/${widget.mobileNumber}/sendotp");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully.")),
        );
        _startTimer(); // restart countdown
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to resend OTP.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP'),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/applogo.jpeg',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "OTP",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("OTP "),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _secondsRemaining == 0 ? _resendOtp : null,
                  child: Text(
                    _secondsRemaining > 0
                        ? "Resend OTP $_secondsRemaining"
                        : "Resend OTP",
                    style: TextStyle(
                      color: _secondsRemaining > 0 ? Colors.black : darkBlue,
                      fontWeight: FontWeight.w500,
                      decoration: _secondsRemaining == 0
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                String otp = _getOtp();
                if (otp.length == 6) {
                  _verifyOtp(otp);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter full OTP.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
