import 'package:flutter/material.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/expense_model.dart';
import 'package:lib_app/providers/expense_provider.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditExpense extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpense({super.key, required this.expense});

  @override
  State<EditExpense> createState() => _EditExpenseState();
}

class _EditExpenseState extends State<EditExpense> {
  bool isLoading = false;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final String? _expenseId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense.name ?? '');
    _priceController = TextEditingController(
      text: widget.expense.amount?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.expense.description ?? '',
    );
    _expenseId = widget.expense.id;
  }

  Future<void> _editExpenseData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLibraryId = prefs.getString('currentLibraryId');
      if (currentLibraryId == null) throw Exception('Library ID not found');

      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final description = _durationController.text.trim();

      final expense = ExpenseModel(
        id: _expenseId,
        name: name,
        amount: price,
        date: widget.expense.date,
        description: description,
      );
      if (!mounted) return;
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).updateexpense(expense, currentLibraryId);

      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Expense updated successfully',
        AppColors.successColor,
      );
      Navigator.pop(context);
      _nameController.clear();
      _priceController.clear();
      _durationController.clear();
    } catch (_) {
      AppSnackbar.showSnackbar(
        context,
        'Failed to update expense. Please try again.',
        AppColors.errorColor,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Edit Expense",
              style: AppTextStyles.appbarTitleText(AppColors.primaryColor),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomLLabelTextField(
                    controller: _nameController,
                    hintText: 'Expense Name',
                    icon: Icons.money,
                    keyboardType: TextInputType.text,
                    validator: validateName,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _priceController,
                    hintText: 'Amount',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: validateDoubleField,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _durationController,
                    hintText: 'Description',
                    icon: Icons.description,
                    keyboardType: TextInputType.text,
                    validator: validateStringField,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Update Expense',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _editExpenseData();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
