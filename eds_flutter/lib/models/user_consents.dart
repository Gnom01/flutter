class UserConsents {
  final bool personalDataProcessingConsent;
  final bool consentReceiveSmsEmailPhone;
  final bool marketingAgreement;

  UserConsents({
    required this.personalDataProcessingConsent,
    required this.consentReceiveSmsEmailPhone,
    required this.marketingAgreement,
  });

  factory UserConsents.fromJson(Map<String, dynamic> json) {
    return UserConsents(
      personalDataProcessingConsent:
          json['PersonalDataProcessingConsent'] ?? false,
      consentReceiveSmsEmailPhone: json['consentReceiveSmsEmailPhone'] ?? false,
      marketingAgreement: json['marketingAgreement'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PersonalDataProcessingConsent': personalDataProcessingConsent,
      'consentReceiveSmsEmailPhone': consentReceiveSmsEmailPhone,
      'marketingAgreement': marketingAgreement,
    };
  }
}
