import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/viewmodels/login_viewmodel.dart';
import 'lib/views/login_view.dart';
import 'views/HomeServiceView.dart';
import 'views/OTPSuccessView.dart'; // If needed
import '../models/UserData.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? customerId = prefs.getString('customerId');
    final String? userDataJson = prefs.getString('userData');
    log('CustomerId---->>$customerId');
    log('Customer Data ---->>$userDataJson');
    if (isLoggedIn && customerId != null) {
      UserData? userData;
      if (userDataJson != null) {
        userData = UserData.fromJson(jsonDecode(userDataJson));
      }
      return HomeServiceView(
        customerId: int.parse(customerId),
        userData: userData,
      );
    }
    return const LoginView();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: MaterialApp(
        title: 'Packerswala Login',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data ?? const LoginView();
          },
        ),
      ),
    );
  }
}