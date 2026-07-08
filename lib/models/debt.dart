class Debt {
  final int? id;
  final String customerName;
  final int amount;
  final String status;

  Debt({
    this.id,
    required this.customerName,
    required this.amount,
    required this.status,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'amount': amount,
      'status': status,
    };
  }

  factory Debt.fromMap(Map<String, Object?> map) {
    return Debt(
      id: map['id'] as int?,
      customerName: map['customer_name'] as String,
      amount: map['amount'] as int,
      status: map['status'] as String,
    );
  }
}
