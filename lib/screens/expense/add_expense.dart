import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  bool isLoading = false;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _addExpenseData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLibraryId = prefs.getString('currentLibraryId');
      if (currentLibraryId == null) throw Exception('Library ID not found');

      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim());
      final description = _descriptionController.text.trim();

      if (price == null) throw Exception('Invalid price');

      final expense = ExpenseModel(
        name: name,
        amount: price,
        description: description,
        date: DateTime.now(),
      );
      if (!mounted) return;
      await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).addexpense(expense, currentLibraryId);

      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'Expense added successfully',
        AppColors.successColor,
      );

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showSnackbar(
          context,
          'Failed to add expense. Please try again.',
          AppColors.errorColor,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              "Add Expense",
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
                    icon: FontAwesomeIcons.fileInvoice,
                    keyboardType: TextInputType.text,
                    validator: validateName,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _priceController,
                    hintText: 'Amount',
                    icon: FontAwesomeIcons.rupeeSign,
                    keyboardType: TextInputType.number,
                    validator: validateDoubleField,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    icon: FontAwesomeIcons.fileAlt,
                    keyboardType: TextInputType.text,
                    validator: validateStringField,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Add Expense',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addExpenseData();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
