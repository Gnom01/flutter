class PaymentItem {
  final int usersPaymentsSchedulesID;
  final String userFullName;
  final String productName;
  final String productAvailableFromDate;
  final String productAvailableToDate;
  final String lastPaymentDate;
  final int usersID;
  final int payerUsersID;
  final String paymentDate;
  final double paymentAmount;
  final int paymentStatusesDVID;
  final int localizationsID;
  final String localizationName;
  bool isSelected;

  PaymentItem({
    required this.usersPaymentsSchedulesID,
    required this.userFullName,
    required this.productName,
    required this.productAvailableFromDate,
    required this.productAvailableToDate,
    required this.lastPaymentDate,
    required this.usersID,
    required this.payerUsersID,
    required this.paymentDate,
    required this.paymentAmount,
    required this.paymentStatusesDVID,
    required this.localizationsID,
    required this.localizationName,
    this.isSelected = true,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    // Parse paymentAmount which can be String or num
    double amount = 0.0;
    if (json['paymentAmount'] != null) {
      if (json['paymentAmount'] is String) {
        amount = double.tryParse(json['paymentAmount']) ?? 0.0;
      } else if (json['paymentAmount'] is num) {
        amount = (json['paymentAmount'] as num).toDouble();
      }
    }

    return PaymentItem(
      usersPaymentsSchedulesID: json['usersPaymentsSchedulesID'] ?? 0,
      userFullName: json['UserFullName'] ?? '',
      productName: json['productName'] ?? '',
      productAvailableFromDate: json['productAvailableFromDate'] ?? '',
      productAvailableToDate: json['productAvailableToDate'] ?? '',
      lastPaymentDate: _formatDate(json['lastPaymentDate'] ?? ''),
      usersID: json['usersID'] ?? 0,
      payerUsersID: json['payer_UsersID'] ?? 0,
      paymentDate: _formatDate(json['paymentDate'] ?? ''),
      paymentAmount: amount,
      paymentStatusesDVID: json['paymentStatusesDVID'] ?? 0,
      localizationsID: json['localizationsID'] ?? 0,
      localizationName: json['localizationName'] ?? '',
    );
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      if (dateStr.contains('T')) {
        final date = DateTime.parse(dateStr);
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }
}

class PaymentScheduleResponse {
  final Map<String, List<PaymentItem>> groups;

  PaymentScheduleResponse({required this.groups});

  factory PaymentScheduleResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<PaymentItem>> groups = {};
    json.forEach((key, value) {
      if (value is List) {
        groups[key] = value.map((item) => PaymentItem.fromJson(item)).toList();
      }
    });
    return PaymentScheduleResponse(groups: groups);
  }
}
