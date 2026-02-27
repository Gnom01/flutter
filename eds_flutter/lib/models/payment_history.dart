class PaymentHistoryPosition {
  final String name;
  final String date;
  final double amount;
  final String status;

  PaymentHistoryPosition({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
  });

  factory PaymentHistoryPosition.fromJson(Map<String, dynamic> json) {
    double amount = 0.0;
    if (json['paymentAmount'] != null) {
      if (json['paymentAmount'] is String) {
        amount = double.tryParse(json['paymentAmount']) ?? 0.0;
      } else if (json['paymentAmount'] is num) {
        amount = (json['paymentAmount'] as num).toDouble();
      }
    }

    return PaymentHistoryPosition(
      name: json['productName'] ?? '',
      date: _formatDate(json['paymentDate'] ?? ''),
      amount: amount,
      status: json['statusName'] ?? 'Nieokreślony',
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

class PaymentHistoryItem {
  final int id;
  final String name;
  final String date;
  final double amount;
  final String status;
  final List<PaymentHistoryPosition> positions;
  bool isExpanded;

  PaymentHistoryItem({
    required this.id,
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
    required this.positions,
    this.isExpanded = false,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    var positionsList = <PaymentHistoryPosition>[];
    if (json['positions'] != null && json['positions'] is List) {
      positionsList = (json['positions'] as List)
          .map((p) => PaymentHistoryPosition.fromJson(p))
          .toList();
    }

    double amount = 0.0;
    if (json['paymentAmount'] != null) {
      if (json['paymentAmount'] is String) {
        amount = double.tryParse(json['paymentAmount']) ?? 0.0;
      } else if (json['paymentAmount'] is num) {
        amount = (json['paymentAmount'] as num).toDouble();
      }
    }

    return PaymentHistoryItem(
      id: json['usersPaymentsID'] ?? 0,
      name: json['productName'] ?? '',
      date: _formatDate(json['paymentDate'] ?? ''),
      amount: amount,
      status: json['statusName'] ?? 'Anulowana', // Default based on screenshot
      positions: positionsList,
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

class PaymentHistoryResponse {
  final List<PaymentHistoryItem> items;

  PaymentHistoryResponse({required this.items});

  factory PaymentHistoryResponse.fromJson(dynamic json) {
    List<PaymentHistoryItem> items = [];
    if (json is List) {
      items = json.map((item) => PaymentHistoryItem.fromJson(item)).toList();
    }
    return PaymentHistoryResponse(items: items);
  }
}
