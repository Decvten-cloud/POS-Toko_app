import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../models/product.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  String _rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return FutureBuilder<List<Object>>(
      future: Future.wait([
        provider.revenueToday(),
        provider.profitToday(),
        provider.transactionCountToday(),
        provider.lowStockProducts(5),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final revenue = snapshot.data?[0] as int? ?? 0;
        final profit = snapshot.data?[1] as int? ?? 0;
        final count = snapshot.data?[2] as int? ?? 0;
        final lowStock = snapshot.data?[3] as List<Product>? ?? [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              const Text('Revenue Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _SummaryCard(label: _rupiah(revenue), value: 'Pendapatan Hari Ini'),
              const SizedBox(height: 20),
              _SummaryCard(label: _rupiah(profit), value: 'Profit Hari Ini'),
              const SizedBox(height: 20),
              _SummaryCard(label: '$count', value: 'Transaksi'),
              const SizedBox(height: 20),
              const Text('Low Stock', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (lowStock.isEmpty)
                const Text('Semua produk cukup stok.', style: TextStyle(fontSize: 18))
              else ...lowStock.map((product) => Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${product.name} (${product.stock} left)', style: const TextStyle(fontSize: 18))),
                          Text(product.unit, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
