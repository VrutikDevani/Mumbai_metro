import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/UserData.dart';
import '../../views/HomeServiceView.dart';
import 'OTPSuccessView.dart';
import 'login_view.dart';

class SignupView extends StatefulWidget {
  final String mobileNumber;

  const SignupView({super.key, required this.mobileNumber});

  static const Color darkBlue = Color(0xFF03669d);
  static const Color mediumBlue = Color(0xFF37b3e7);
  static const Color lightBlue = Color(0xFF7ed2f7);
  static const Color whiteColor = Color(0xFFf7f7f7);

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  String? selectedState;
  bool isLoading = false;

  final List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
    'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  Future<bool> createUser() async {
    try {
      final url = 'http://54kidsstreet.org/api/customers';
      developer.log('[SignupView] 🌐 Creating User URL: $url', name: 'flutter', level: 800);

      final client = http.Client();
      final request = http.Request('POST', Uri.parse(url))
        ..headers.addAll({
          'Content-Type': 'application/x-www-form-urlencoded',
        })
        ..bodyFields = {
          'customer_name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'pincode': pincodeController.text.trim(),
          'city': cityController.text.trim(),
          'state': selectedState ?? '',
          'mobile_no': widget.mobileNumber,
        };

      final response = await client.send(request).then((response) async {
        return await http.Response.fromStream(response);
      });

      developer.log('[SignupView] 📊 Create User Response Status: ${response.statusCode}',
          name: 'flutter', level: 800);
      developer.log('[SignupView] 📝 Create User Response Body: ${response.body}',
          name: 'flutter', level: 800);
      developer.log('[SignupView] 📍 Redirect Location: ${response.headers['location'] ?? 'N/A'}',
          name: 'flutter', level: 800);
      developer.log('[SignupView] 📋 Full Headers: ${response.headers}',
          name: 'flutter', level: 800);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          try {
            final responseData = json.decode(response.body);
            developer.log('[SignupView] ✅ Parsed Response: $responseData',
                name: 'flutter', level: 800);

            if (responseData is Map && responseData.containsKey('data')) {
              final data = responseData['data'];
              if (data is Map && data['id'] != null) {
                // Save login state and customerId
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true);
                await prefs.setString('customerId', data['id'].toString());
                // Save UserData
                final userData = UserData(
                  customerName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  pincode: pincodeController.text.trim(),
                  city: cityController.text.trim(),
                  state: selectedState ?? '',
                  mobileNo: widget.mobileNumber,
                );
                await prefs.setString('userData', jsonEncode(userData.toJson()));
                developer.log('[SignupView] ✅ User creation successful',
                    name: 'flutter', level: 800);
                return true;
              }
            }
            developer.log('[SignupView] ❌ Response does not indicate success: $responseData',
                name: 'flutter', level: 800);
            return false;
          } catch (e) {
            developer.log('[SignupView] ⚠️ JSON parsing error: $e',
                name: 'flutter', level: 800);
            return false;
          }
        } else {
          developer.log('[SignupView] ❌ Empty response body for user creation',
              name: 'flutter', level: 800);
          return false;
        }
      } else {
        developer.log('[SignupView] ❌ User creation failed with status: ${response.statusCode} - ${response.body}',
            name: 'flutter', level: 800);
        return false;
      }
    } catch (e) {
      developer.log('[SignupView] 💥 Error creating user: $e',
          name: 'flutter', level: 800);
      return false;
    }
  }

  void submitSignupForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      bool isCreated = await createUser();

      setState(() {
        isLoading = false;
      });

      if (isCreated) {
        // Create UserData object with form data
        final userData = UserData(
          customerName: nameController.text.trim(),
          email: emailController.text.trim(),
          pincode: pincodeController.text.trim(),
          city: cityController.text.trim(),
          state: selectedState ?? '',
          mobileNo: widget.mobileNumber,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeServiceView(userData: userData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create account. Please contact support at support@54kidsstreet.org.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: SignupView.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Fill The Form',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    } else if (!isValidEmail(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: pincodeController,
                  decoration: const InputDecoration(
                    labelText: 'Pincode*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.trim().isEmpty || value.length != 6
                      ? 'Please enter a valid 6-digit pincode'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter your city'
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'State*',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedState,
                  isExpanded: true,
                  items: indianStates
                      .map((state) => DropdownMenuItem(
                    value: state,
                    child: Text(
                      state,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select your state' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : submitSignupForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SignupView.darkBlue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                      : const Text(
                    'Signup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginView(),
                          ),
                              (route) => false,
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}