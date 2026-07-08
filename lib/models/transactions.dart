class TransactionRecord {
  final int? id;
  final int total;
  final int profit;
  final String createdAt;

  TransactionRecord({
    this.id,
    required this.total,
    required this.profit,
    required this.createdAt,
  });
}

class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int quantity;
  final int subtotal;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.subtotal,
  });
}
