import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> get expenses => _expenses;

  double get totalExpense {
    double total = 0;
    for (var expense in _expenses) {
      total += expense.amount ?? 0;
    }
    return total;
  }

  List<ExpenseModel> get expensesThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _expenses.where((expense) {
      final date = expense.date;
      return date != null &&
          date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<ExpenseModel> get expensesThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return _expenses.where((expense) {
      final date = expense.date;
      return date != null &&
          date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
          date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  double get totalExpenseThisMonth {
    return expensesThisMonth.fold(
      0,
      (sum, expense) => sum + (expense.amount ?? 0),
    );
  }

  Future<void> loadexpenses(String libraryId) async {
    final snapshot =
        await _firestore.collection('libraries/$libraryId/expenses').get();
    _expenses =
        snapshot.docs.map((doc) => ExpenseModel.fromDocument(doc)).toList();
    notifyListeners();
  }

  Future<void> addexpense(ExpenseModel expense, String libraryId) async {
    final ref = await _firestore
        .collection('libraries/$libraryId/expenses')
        .add(expense.toDocument());
    expense.id = ref.id;
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> updateexpense(ExpenseModel expense, String libraryId) async {
    await _firestore
        .collection('libraries/$libraryId/expenses')
        .doc(expense.id)
        .update(expense.toDocument());
    final index = _expenses.indexWhere((p) => p.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  Future<void> deleteexpense(String id, String libraryId) async {
    await _firestore
        .collection('libraries/$libraryId/expenses')
        .doc(id)
        .delete();
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  void clear() {
    _expenses = [];
    notifyListeners();
  }
}
