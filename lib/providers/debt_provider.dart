import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/debt.dart';

class DebtProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final List<Debt> _debts = [];
  bool _isLoading = false;

  DebtProvider() {
    loadDebts();
  }

  List<Debt> get debts => List.unmodifiable(_debts);
  bool get isLoading => _isLoading;

  Future<void> loadDebts() async {
    _isLoading = true;
    notifyListeners();
    final debts = await _db.getDebts();
    _debts.clear();
    _debts.addAll(debts);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    await _db.insertDebt(debt);
    await loadDebts();
  }

  Future<void> updateDebtStatus(int id, String status) async {
    await _db.updateDebtStatus(id, status);
    await loadDebts();
  }

  Future<void> deleteDebt(int id) async {
    await _db.deleteDebt(id);
    await loadDebts();
  }
}
