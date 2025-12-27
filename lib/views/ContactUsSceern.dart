import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// Import the rich ContactUsModel from your app_policy_model.dart
import 'package:new_packers_application/lib/models/app_policy_model.dart';
import 'package:new_packers_application/lib/constant/app_color.dart'; // Assuming AppColor is defined here

// --- Utility function to launch URLs (Unchanged) ---
Future<void> _launchUrl(String url) async {
  if (url.isEmpty) return;
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // Fail silently or log error, avoiding alerts/snackbars here
    debugPrint('Could not launch $url');
  }
}

class ContactUsScreen extends StatelessWidget {
  // Accept the fully populated ContactUsModel object via the constructor
  final ContactUsModel contactData;

  const ContactUsScreen({super.key, required this.contactData});

  // Define a consistent color scheme
  static const Color primaryColor =
      Color(0xFF1976D2); // Example for AppColor.darkBlue

  // Helper for opening maps (using the address)
  void _openInMaps(String address) {
    if (address.isEmpty) return;
    final encodedAddress = Uri.encodeComponent(address);
    final mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    _launchUrl(mapUrl);
  }

  // Helper for making calls
  void _makeCall(String phoneNumber) {
    if (phoneNumber.isEmpty) return;
    final uri = Uri.parse('tel:$phoneNumber');
    launchUrl(uri);
  }

  // Helper for WhatsApp chat
  Future<void> _openWhatsApp(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    // Remove all non-digit characters to get a clean number (e.g., 919920718084)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    // Using wa.me link is more reliable and supports web fallback
    final whatsappUrl = 'https://wa.me/$cleanNumber';

    final uri = Uri.parse(whatsappUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $whatsappUrl');
    }
  }

  // Helper for sending email
  void _sendEmail(String email) {
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email');
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    // The main scaffold with AppBar matching the original
    return Scaffold(
      appBar: AppBar(
        title: Text(
          contactData.title.isNotEmpty ? contactData.title : 'Contact Us',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColor.darkBlue, // Use your defined AppColor
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Logo and Header ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/applogo.jpeg', // Use a consistent logo asset
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "MUMBAI METRO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    "PACKERS AND MOVERS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColor.darkBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'GET IN TOUCH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),
            const SizedBox(height: 20),

            // --- Office Address Section ---
            _buildAddressSection(context, contactData, AppColor.darkBlue),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  debugPrint(contactData.websiteLink);
                  _launchUrl(contactData.websiteLink ?? "");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Visit our Website',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Sales and Support Cards ---
            // --- Sales and Support Cards (Vertical Stack) ---
            _buildNewContactCard(
              context,
              title: 'Sales',
              icon: Icons.support_agent, // Or appropriate icon
              phone: contactData.contact1,
              email: contactData.email,
              emailLabel: 'Sales email ID',
              primaryColor: AppColor.darkBlue,
            ),

            const SizedBox(height: 20),

            _buildNewContactCard(
              context,
              title: 'Support',
              icon: Icons.headset_mic, // Or appropriate icon
              phone: contactData.contact2,
              email: contactData.email2,
              emailLabel: 'Support email ID',
              primaryColor: AppColor.darkBlue,
            ),

            const SizedBox(height: 40),

            // --- Follow & Connect With Us Section ---
            const Text(
              'Follow & Connect With Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _buildSocialMediaRow(contactData, AppColor.darkBlue),
          ],
        ),
      ),
    );
  }

  // --- Reusable Widget Builders ---

  Widget _buildAddressSection(
      BuildContext context, ContactUsModel data, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Our Office Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Text(
            data.address,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.map,
                text: 'Open in Maps',
                color: primaryColor,
                onPressed: () {
                  if (data.mapLocationLink.isNotEmpty) {
                    _launchUrl(data.mapLocationLink);
                  } else {
                    _openInMaps(data.address);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share,
                text: 'Share App',
                color: primaryColor,
                onPressed: () {
                  debugPrint('Share App button pressed');
                  if (data.shareAppLink.isNotEmpty) {
                    Share.share(data.shareAppLink);
                  } else {
                    debugPrint('Share link is empty!');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share link is not available')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewContactCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String phone,
    required String email,
    required String emailLabel,
    required Color primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Icon + Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: primaryColor, size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone Number Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Light grey background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  phone.isNotEmpty ? phone : '+91 0000000000',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Email Section
          Text(
            emailLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _sendEmail(email),
            child: Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons Row: Call Now & WhatsApp
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall(phone),
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text(
                    'Call Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(phone),
                  icon: const Icon(Icons.chat_bubble,
                      color: Colors
                          .white), // Using chat_bubble for generic chat icon
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaRow(ContactUsModel data, Color primaryColor) {
    final socialLinks = [
      {'url': data.facebook, 'icon': data.facebookIcon},
      {'url': data.instagram, 'icon': data.instagramIcon},
      {'url': data.twitter, 'icon': data.twitterIcon},
      {'url': data.linkedin, 'icon': data.linkedinIcon},
      {'url': data.youtube, 'icon': data.youtubeIcon},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: socialLinks.map((entry) {
        final url = entry['url'] as String;
        final iconUrl = entry['icon'] as String;

        // Only build if we have a valid icon URL
        if (url.isNotEmpty && iconUrl.isNotEmpty) {
          return _buildSocialNetworkIcon(
            imageUrl: iconUrl,
            url: url,
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildSocialNetworkIcon(
      {required String imageUrl, required String url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a generic icon if network image fails
                return const Icon(Icons.link, size: 20, color: Colors.grey);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Keep the original _buildSocialIcon if you need it elsewhere, otherwise it can be removed ---
  Widget _buildSocialIcon({
    required IconData icon,
    required String url,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: url.isNotEmpty ? () => _launchUrl(url) : null,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
