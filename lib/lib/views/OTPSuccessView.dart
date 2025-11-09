import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '/views/PendingScreen.dart';
import '/views/PartnerSuccessScreen.dart';
import '/views/PartnerWithUsScreen.dart';

import '/viewmodels/shift_house_viewmodel.dart';

import '/views/shift_house_screen.dart';
import 'MyRequestScreen.dart';



// Logo color constants
const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class OTPSuccessView extends StatefulWidget {
  const OTPSuccessView({super.key});

  @override
  _OTPSuccessViewState createState() => _OTPSuccessViewState();
}

class _OTPSuccessViewState extends State<OTPSuccessView> {
  final List<String> images = [
    'assets/parcelwala4.jpg',
    'assets/parcelwala5.jpg',
    'assets/parcelwala6.jpg',
    'assets/parcelwala7.jpg',
    'assets/parcelwala8.jpg',
    'assets/parcelwala9.jpg',
  ];
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % images.length;
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '8888888888');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  void _openWhatsApp() async {
    final String phoneNumber = '919022062666';
    final String message = 'Hello from Mumbai Metro Packers & Movers app';
    final String whatsappAppUrl =
        'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
    final Uri whatsappAppUri = Uri.parse(whatsappAppUrl);

    if (await canLaunchUrl(whatsappAppUri)) {
      await launchUrl(whatsappAppUri);
    } else {
      final String whatsappWebUrl =
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
      final Uri whatsappWebUri = Uri.parse(whatsappWebUrl);
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('WhatsApp is not installed on this device')),
        );
      }
    }
  }

  void _navigateToShiftHouse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => ShiftHouseViewModel(),
          child: const ShiftHouseScreen(),
        ),
      ),
    );
  }

  //void _navigateToMyRequest() {
 // /   Navigator.push(
 //      context,
 //      MaterialPageRoute(builder: (context) => const MyRequestScreen()),
 //    );
 //  }

  void _navigateToPending() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PendingScreen()),
    );
  }

  void _navigateToPartnerWithUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PartnerWithUsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Mumbai Metro Packers',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: _navigateToPending,
          ),
        ),
      ),
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hi, Suraj Supekar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 200,
                      color: lightBlue,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(images[index], fit: BoxFit.cover);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(16.0),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.0,
                      children: [
                        _buildButton('Shift My House', Icons.home,
                            onTap: _navigateToShiftHouse),
                        _buildButton('Shift My Office', Icons.business,onTap: _navigateToShiftHouse),
                        _buildButton('Get Quotation', Icons.description),
                        _buildButton('My Request', Icons.check_circle,
                          //  onTap: _navigateToMyRequest

                        ),
                        _buildButton('Partner With Us', Icons.handshake,
                            onTap: _navigateToPartnerWithUs),
                        _buildButton('Chat now', Icons.chat,
                            onTap: _openWhatsApp),
                        _buildButton('Call us', Icons.call,
                            onTap: _makePhoneCall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _openWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Chat with us',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, {VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap ??
              () {
            if (title == 'Call us') _makePhoneCall();
            else if (title == 'Chat now') _openWhatsApp();
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        side: const BorderSide(color: mediumBlue, width: 2),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: mediumBlue, size: 24),
          const SizedBox(height: 5),
          Text(title,
              style: const TextStyle(color: mediumBlue, fontSize: 12)),
        ],
      ),
    );
  }
}
