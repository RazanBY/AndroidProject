class WalletTransaction {
  final int id;
  final double amount;
  final String type; // deposit, payment
  final DateTime timestamp;
  final int? bookingId;
  final String? bookingStatus;
  final String? serviceName;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.bookingId,
    this.bookingStatus,
    this.serviceName,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      bookingId: json['booking_id'] as int?,
      bookingStatus: json['booking_status'] as String?,
      serviceName: json['service_name'] as String?,
    );
  }
}

class WalletSummary {
  final double totalDeposits;
  final double totalPayments;
  final double netBalance;
  final int count;

  WalletSummary({
    required this.totalDeposits,
    required this.totalPayments,
    required this.netBalance,
    required this.count,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalDeposits: (json['totalDeposits'] as num).toDouble(),
      totalPayments: (json['totalPayments'] as num).toDouble(),
      netBalance: (json['netBalance'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

