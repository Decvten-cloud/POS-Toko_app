import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt.dart';
import '../providers/debt_provider.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  String _rupiah(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  Future<void> _showAddDebtDialog(
    BuildContext context,
    DebtProvider provider,
  ) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        final navigator = Navigator.of(context);
        return AlertDialog(
          title: const Text('Tambah Utang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amount = int.tryParse(amountController.text) ?? 0;
                if (name.isEmpty || amount <= 0) return;
                await provider.addDebt(
                  Debt(
                    customerName: name,
                    amount: amount,
                    status: 'Belum Lunas',
                  ),
                );
                navigator.pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DebtProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAddDebtDialog(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Utang'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.debts.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada utang saat ini.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    itemCount: provider.debts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final debt = provider.debts[index];
                      final paid = debt.status.toLowerCase() == 'lunas';
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      debt.customerName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _rupiah(debt.amount),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Status: ${debt.status}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: paid ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      provider.updateDebtStatus(
                                        debt.id!,
                                        paid ? 'Belum Lunas' : 'Lunas',
                                      );
                                    },
                                    child: Text(paid ? 'Batalkan' : 'Bayar'),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      provider.deleteDebt(debt.id!);
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
