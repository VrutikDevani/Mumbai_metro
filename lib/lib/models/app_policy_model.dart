// --- 1. PolicyItem (Unchanged) ---
// Used for privacy_policy, terms_condition, and refund_policy.
class PolicyItem {
  final String title;
  final String content;

  PolicyItem({
    required this.title,
    required this.content,
  });

  factory PolicyItem.fromJson(Map<String, dynamic> json) {
    return PolicyItem(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// --- 2. AboutUsModel (For about_us) ---
// Functionally the same as PolicyItem, but provides clearer type distinction.
class AboutUsModel {
  final String title;
  final String content;

  AboutUsModel({
    required this.title,
    required this.content,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

// --- 3. ContactUsModel (For contact_us) ---
// This class captures all the specific contact details.
class ContactUsModel {
  final String title;
  final String content;
  final String email;
  final String contact1;
  final String contact2;
  final String facebook;
  final String instagram;
  final String twitter;
  final String linkedin;
  final String youtube;
  final String address;
  final String email2;
  final String facebookIcon;
  final String instagramIcon;
  final String twitterIcon;
  final String linkedinIcon;
  final String youtubeIcon;
  final String mapLocationLink;
  final String shareAppLink;
  final String websiteLink;

  ContactUsModel({
    required this.title,
    required this.content,
    required this.email,
    required this.contact1,
    required this.contact2,
    required this.facebook,
    required this.instagram,
    required this.twitter,
    required this.linkedin,
    required this.youtube,
    required this.address,
    required this.email2,
    required this.facebookIcon,
    required this.instagramIcon,
    required this.twitterIcon,
    required this.linkedinIcon,
    required this.youtubeIcon,
    required this.mapLocationLink,
    required this.shareAppLink,
    required this.websiteLink,
  });

  factory ContactUsModel.fromJson(Map<String, dynamic> json) {
    return ContactUsModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      email: json['email'] ?? '',
      contact1: json['contact1'] ?? '',
      contact2: json['contact2'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
      linkedin: json['linkedin'] ?? '',
      youtube: json['youtube'] ?? '',
      address: json['address'] ?? '',
      email2: json['email2'] ?? '',
      facebookIcon: json['facebook_icon'] ?? '',
      instagramIcon: json['instagram_icon'] ?? '',
      twitterIcon: json['twitter_icon'] ?? '',
      linkedinIcon: json['linkedin_icon'] ?? '',
      youtubeIcon: json['youtube_icon'] ?? '',
      mapLocationLink: json['map_location_link'] ?? '',
      shareAppLink: json['share_app_link'] ?? '',
      websiteLink: json['website_link'] ?? '',
    );
  }
}

// --- 4. PolicyData (Updated) ---
// This class now uses the specialized models for ContactUs and AboutUs.
class PolicyData {
  final PolicyItem privacyPolicy;
  final PolicyItem termsCondition;
  final PolicyItem refundPolicy;
  final ContactUsModel contactUs; // Changed from PolicyItem to ContactUsModel
  final PolicyItem aboutUs; // Changed from PolicyItem to AboutUsModel
  final HomePageModel homePage;

  PolicyData({
    required this.privacyPolicy,
    required this.termsCondition,
    required this.refundPolicy,
    required this.contactUs,
    required this.aboutUs,
    required this.homePage,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      privacyPolicy: PolicyItem.fromJson(json['privacy_policy'] ?? {}),
      termsCondition: PolicyItem.fromJson(json['terms_condition'] ?? {}),
      refundPolicy: PolicyItem.fromJson(json['refund_policy'] ?? {}),
      // Map to the new specialized models
      contactUs: ContactUsModel.fromJson(json['contact_us'] ?? {}),
      aboutUs: PolicyItem.fromJson(json['about_us'] ?? {}),
      homePage: HomePageModel.fromJson(json['home-page'] ?? {}),
    );
  }
}

// --- 6. HomePageModel (New) ---
class HomePageModel {
  final String chatNumber;
  final String callNumber;

  HomePageModel({
    required this.chatNumber,
    required this.callNumber,
  });

  factory HomePageModel.fromJson(Map<String, dynamic> json) {
    return HomePageModel(
      chatNumber: json['chat_number'] ?? '',
      callNumber: json['call_number'] ?? '',
    );
  }
}

// --- 5. PolicyModel (Updated) ---
// This class remains mostly the same, ensuring it uses the updated PolicyData.
class PolicyModel {
  final bool status;
  final String message;
  final PolicyData data;

  PolicyModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: PolicyData.fromJson(json['data'] ?? {}),
    );
  }
}
