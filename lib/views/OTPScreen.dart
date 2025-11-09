import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../lib/views/signup_view.dart';
import 'HomeServiceView.dart';
import '../models/OtpResponse.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final int source;

  const OTPScreen({super.key, required this.mobileNumber, required this.source});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with CodeAutoFill {
  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);

  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  bool isResendLoading = false;
  int resendTimer = 30;
  Timer? timer;
  String? appSignature;

  @override
  void initState() {
    super.initState();
    startResendTimer();
    _initSmsListener();
  }

  // Initialize SMS listener
  Future<void> _initSmsListener() async {
    try {
      // Get app signature (needed for SMS retriever API)
      appSignature = await SmsAutoFill().getAppSignature;
      developer.log('[OTPScreen] App Signature: $appSignature', name: 'flutter');

      // Listen for OTP
      await SmsAutoFill().listenForCode();

      developer.log('[OTPScreen] SMS Listener initialized', name: 'flutter');
    } catch (e) {
      developer.log('[OTPScreen] Error initializing SMS listener: $e', name: 'flutter');
    }
  }

  @override
  void codeUpdated() {
    // This method is called when OTP is detected
    if (code != null && code!.length == 6) {
      developer.log('[OTPScreen] OTP Auto-filled: $code', name: 'flutter');

      // Fill OTP fields
      for (int i = 0; i < 6; i++) {
        otpControllers[i].text = code![i];
      }

      // Auto-submit after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          submitOTP();
        }
      });
    }
  }

  void startResendTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Cancel SMS listener
    SmsAutoFill().unregisterListener();
    timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOTP() {
    final otp = otpControllers.map((controller) => controller.text).join().trim();
    return otp;
  }

  Future<OtpResponse?> verifyOTP(String otp) async {
    try {
      String baseUrl = 'http://54kidsstreet.org';
      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otpverify?otp=$otp';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            developer.log('[OTPScreen] ✅ Parsed Response: $responseData',
                name: 'flutter', level: 800);

            OtpResponse otpResponse = OtpResponse.fromJson(responseData);

            if (otpResponse.status) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              await prefs.setString('customerId', otpResponse.customerId.toString());
              return otpResponse;
            } else {
              return null;
            }
          } catch (e) {
            return OtpResponse(status: true, msg: 'OTP verified successfully', customerId: 0);
          }
        } else {
          return OtpResponse(status: true, msg: 'OTP verified successfully', customerId: 0);
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> resendOTP() async {
    try {
      String baseUrl = 'http://54kidsstreet.org';
      final url = '$baseUrl/api/customers/${widget.mobileNumber}/otp';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Re-initialize SMS listener after resend
        await _initSmsListener();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void onOTPChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void submitOTP() async {
    String otp = getOTP();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    OtpResponse? otpResponse = await verifyOTP(otp);

    setState(() {
      isLoading = false;
    });

    if (otpResponse != null && otpResponse.status) {
      if (widget.source == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeServiceView(
              customerId: otpResponse.customerId,
            ),
          ),
        );
      } else if (widget.source == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupView(
              mobileNumber: widget.mobileNumber,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );

      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    }
  }

  void handleResendOTP() async {
    if (resendTimer > 0 || isResendLoading) return;

    setState(() {
      isResendLoading = true;
    });

    bool otpSent = await resendOTP();

    setState(() {
      isResendLoading = false;
    });

    if (otpSent) {
      setState(() {
        resendTimer = 120;
      });
      startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/applogo.jpeg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Auto-fill enabled',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: resendTimer == 0 && !isResendLoading ? handleResendOTP : null,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 14,
                              color: resendTimer > 0 ? Colors.grey : darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (resendTimer > 0)
                          Text(
                            resendTimer >= 60
                                ? '${(resendTimer ~/ 60).toString().padLeft(2, '0')}:${(resendTimer % 60).toString().padLeft(2, '0')}'
                                : '$resendTimer',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else if (isResendLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: handleResendOTP,
                            child: const Icon(
                              Icons.refresh,
                              color: darkBlue,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => onOTPChanged(value, index),
                      onTap: () {
                        otpControllers[index].selection =
                            TextSelection.fromPosition(
                              TextPosition(offset: otpControllers[index].text.length),
                            );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}