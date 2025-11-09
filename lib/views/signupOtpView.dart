import 'package:flutter/material.dart';// imp
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/viewmodels/login_viewmodel.dart';
import '../lib/views/login_view.dart';
import '../lib/views/signup_view.dart';
import 'OTPScreen.dart';

class signupOtpView extends StatelessWidget {
  const signupOtpView({super.key});

  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);
  static const Color whiteColor = Color(0xFFf7f7f7);

  // Function to send OTP
  Future<bool> sendOTP(String mobileNumber) async {
    try {
      String baseUrl = 'http://54kidsstreet.org'; // For domain
      // String baseUrl = 'http://127.0.0.1:8000'; // For localhost - uncomment if needed

      final url = '$baseUrl/api/customers/$mobileNumber/otp';
      print('Sending OTP to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Send OTP Response Status: ${response.statusCode}');
      print('Send OTP Response Body: ${response.body}');
      print('Send OTP Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('OTP sent successfully for $mobileNumber');
        return true;
      } else {
        print('Failed to send OTP: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Signup'),
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
                  TextField(
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      counterText: '',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              '🇮🇳',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+91',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      viewModel.setMobileNumber(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      if (viewModel.mobileNumber.length == 10) {
                        viewModel.setLoading(true);

                        bool otpSent = await sendOTP(viewModel.mobileNumber);

                        viewModel.setLoading(false);

                        if (otpSent) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTPScreen(
                                mobileNumber: viewModel.mobileNumber,
                                  source: 2
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to send OTP. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid 10-digit mobile number'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Add Number',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: const Text('Already have an account? Login'),
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