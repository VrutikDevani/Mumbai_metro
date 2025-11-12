

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

class PolicyData {
  final PolicyItem privacyPolicy;
  final PolicyItem termsCondition;
  final PolicyItem refundPolicy;
  final PolicyItem contactUs;
  final PolicyItem aboutUs;

  PolicyData({
    required this.privacyPolicy,
    required this.termsCondition,
    required this.refundPolicy,
    required this.contactUs,
    required this.aboutUs,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      privacyPolicy: PolicyItem.fromJson(json['privacy_policy'] ?? {}),
      termsCondition: PolicyItem.fromJson(json['terms_condition'] ?? {}),
      refundPolicy: PolicyItem.fromJson(json['refund_policy'] ?? {}),
      contactUs: PolicyItem.fromJson(json['contact_us'] ?? {}),
      aboutUs: PolicyItem.fromJson(json['about_us'] ?? {}),
    );
  }
}

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
