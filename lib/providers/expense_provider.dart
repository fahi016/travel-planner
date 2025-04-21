import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  late Box<List<dynamic>> _expenseBox;
  final Map<dynamic, List<Expense>> _expenses = {};

  ExpenseProvider() {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    _expenseBox = Hive.box<List<dynamic>>('expenses');
    await loadExpenses();
  }

  List<Expense> getExpensesForTrip(dynamic tripId) {
    return _expenses[tripId] ?? [];
  }

  Future<void> addExpense(dynamic tripId, Expense expense) async {
    if (!_expenses.containsKey(tripId)) {
      _expenses[tripId] = [];
    }
    _expenses[tripId]!.add(expense);
    await _saveExpenses(tripId);
    notifyListeners();
  }

  Future<void> deleteExpense(dynamic tripId, Expense expense) async {
    _expenses[tripId]?.remove(expense);
    await _saveExpenses(tripId);
    notifyListeners();
  }

  Future<void> _saveExpenses(dynamic tripId) async {
    final expenseList = _expenses[tripId]?.map((e) => {
          'category': e.category,
          'amount': e.amount,
          'note': e.note,
          'date': e.date.toIso8601String(),
        }).toList();
    
    if (expenseList != null) {
      await _expenseBox.put(tripId, expenseList);
    }
  }

  Future<void> loadExpenses() async {
    _expenses.clear();
    for (var key in _expenseBox.keys) {
      final expenseList = _expenseBox.get(key);
      if (expenseList != null) {
        _expenses[key] = expenseList.map((e) => Expense(
              category: e['category'] as String,
              amount: (e['amount'] as num).toDouble(),
              note: e['note'] as String,
              date: DateTime.parse(e['date'] as String),
            )).toList();
      }
    }
    notifyListeners();
  }

  Future<void> deleteAllExpenses() async {
    await _expenseBox.clear();
    _expenses.clear();
    notifyListeners();
  }

  Future<void> deleteExpensesForTrip(dynamic tripId) async {
    await _expenseBox.delete(tripId);
    _expenses.remove(tripId);
    notifyListeners();
  }

  double getTotalExpensesForTrip(dynamic tripId) {
    return _expenses[tripId]?.fold(
          0.0,
          (sum, expense) => sum! + expense.amount,
        ) ??
        0.0;
  }

  Map<String, double> getCategoryTotalsForTrip(dynamic tripId) {
    final expenses = _expenses[tripId] ?? [];
    final categoryTotals = <String, double>{};

    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }
} 