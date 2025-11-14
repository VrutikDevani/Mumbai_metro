import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_packers_application/lib/constant/app_drawer.dart';
import 'package:new_packers_application/views/VendorRegScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../lib/models/customer_data_model.dart';
import '../lib/views/MyRequestScreen.dart';
import '../lib/views/login_view.dart';
import '../models/UserData.dart';
import 'SubCategoryScreen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class HomeServiceView extends StatefulWidget {
  const HomeServiceView();

  @override
  State<HomeServiceView> createState() => _HomeServiceViewState();
}

class _HomeServiceViewState extends State<HomeServiceView> {
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  List<dynamic> categories = [];
  List<String> bannerImages = [];
  bool isLoadingCategories = true;
  bool isLoadingBanners = true;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _fetchCategories();
    _fetchBanners();
  }

  CustomerModel? customerModel;

  bool isLoading = false;

  fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String baseUrl = "http://54kidsstreet.org";

      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString('customerId');
      final response = await http.get(
        Uri.parse("$baseUrl/api/customer/${customerId ?? ''}"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      log("➡ API Response: ${response.body}");

      if (response.statusCode == 200) {
        customerModel = CustomerModel.fromJson(jsonDecode(response.body));
      } else {
        log("⚠ Something went wrong");
      }
    } catch (e) {
      log("❌ Error fetching customer: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted && bannerImages.isNotEmpty) {
        setState(() {
          currentIndex = (currentIndex + 1) % bannerImages.length;
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse("https://54kidsstreet.org/api/category"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          categories = jsonData["data"];
          isLoadingCategories = false;
        });
      } else {
        setState(() => isLoadingCategories = false);
      }
    } catch (e) {
      setState(() => isLoadingCategories = false);
    }
  }

  Future<void> _fetchBanners() async {
    try {
      final response =
          await http.get(Uri.parse("https://54kidsstreet.org/api/banner"));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> banners = jsonData["data"];

        setState(() {
          bannerImages = banners
              .map<String>((b) =>
                  "https://54kidsstreet.org/admin_assets/banners/${b["image"]}")
              .toList();

          if (bannerImages.isEmpty) {
            _useFallbackBanners();
          } else {
            _startBannerTimer();
          }
          isLoadingBanners = false;
        });
      } else {
        _useFallbackBanners();
      }
    } catch (e) {
      _useFallbackBanners();
    }
  }

  void _useFallbackBanners() {
    setState(() {
      bannerImages = [
        'assets/parcelwala4.jpg',
        'assets/parcelwala5.jpg',
        'assets/parcelwala6.jpg',
        'assets/parcelwala7.jpg',
      ];
      isLoadingBanners = false;
      _startBannerTimer();
    });
  }

  bool _isNetworkImage(String imagePath) {
    return imagePath.startsWith('http://') || imagePath.startsWith('https://');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('customerId');
    await prefs.remove('userData');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMyRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MyRequestScreen(customerId: int.parse(customerId ?? '0')),
      ),
    );
  }

  void _navigateToVendorReg() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorRegScreen(),
      ),
    );
  }

  void _openWhatsApp() async {
    final String phoneNumber = '919022062666';
    final String message = 'Hello from HomeServiceView';

    final Uri whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    );

    final Uri whatsappWebUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappAppUri);
    } catch (e) {
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
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

  Widget _buildButton(String title, IconData icon, {VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap ?? () {},
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
          Icon(icon, color: mediumBlue, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(Map<String, dynamic> category) {
    String name = category["name"] ?? "Unknown";
    String? bannerImg = category["category_banner_img"];
    String? description = category["category_desc"];

    String? imageUrl = category["icon_image"] != null &&
            category["icon_image"].isNotEmpty
        ? "https://54kidsstreet.org/admin_assets/category_icon_img/${category["icon_image"]}"
        : null;
    IconData defaultIcon = Icons.category;

    return ElevatedButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        final String? customerId = prefs.getString('customerId');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoryScreen(
              categoryId: category["id"],
              categoryName: name,
              customerId: int.parse(customerId ?? '0'),
              categoryBannerImg: bannerImg,
              categoryDesc: description,
            ),
          ),
        );
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? SizedBox(
                    height: 28,
                    width: 28,
                    child: ClipRRect(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/parcelwala4.jpg',
                        image: imageUrl,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        imageErrorBuilder: (context, error, stackTrace) {
                          print(
                              'Failed to load image for $name: $imageUrl, Error: $error');
                          return Icon(defaultIcon, color: mediumBlue, size: 28);
                        },
                      ),
                    ),
                  )
                : Icon(defaultIcon, color: mediumBlue, size: 28),
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      //
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Mumbai Metro Packers and Movers',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        centerTitle: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: whiteColor),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
              ),
            ),
          )
          : Container(
              color: whiteColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hi, ${customerModel?.data.customerName ?? 'User'}',
                        style: const TextStyle(
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
                    child: isLoadingBanners
                        ? const Center(child: CircularProgressIndicator())
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: bannerImages.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final imagePath = bannerImages[index];
                              final isNetwork = _isNetworkImage(imagePath);

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: isNetwork
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/parcelwala4.jpg',
                                        image: imagePath,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder: (c, e, s) =>
                                            Image.asset(
                                                'assets/parcelwala4.jpg',
                                                fit: BoxFit.cover),
                                      )
                                    : Image.asset(imagePath, fit: BoxFit.cover),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(16.0),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.0,
                            children: [
                              ...categories
                                  .map((cat) => _buildCategoryButton(cat)),
                              _buildButton('My Booking', Icons.check_circle,
                                  onTap: _navigateToMyRequest),
                              _buildButton('Call Us', Icons.call,
                                  onTap: _makePhoneCall),
                              _buildButton(
                                'Vendor Registration',
                                Icons.person,
                                onTap: _navigateToVendorReg,
                              ),
                            ],
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
}
