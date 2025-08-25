import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/expense_provider.dart';
import 'package:lib_app/screens/expense/add_expense.dart';
import 'package:lib_app/screens/expense/edit_expense.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Viewexpenses extends StatefulWidget {
  final bool? isNavigation;
  const Viewexpenses({super.key, this.isNavigation});

  @override
  State<Viewexpenses> createState() => _ViewexpensesState();
}

class _ViewexpensesState extends State<Viewexpenses> {
  String? currentLibraryId;
  bool viewAll = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (currentLibraryId == null) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      setState(() => isLoading = false);
      return;
    }
    if (!mounted) return;
    await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).loadexpenses(currentLibraryId!);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }
    final expenses =
        viewAll ? expenseProvider.expenses : expenseProvider.expensesThisWeek;
    return Scaffold(
      backgroundColor: AppColors.backgroundBlueColor,
      appBar:
          (widget.isNavigation ?? false)
              ? AppAppBar(title: 'View Expenses')
              : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _onAddExpense,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body:
          expenseProvider.expenses.isEmpty
              ? Center(
                child: Text(
                  'No Expenses Added',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummary(expenseProvider),
                    const SizedBox(height: 20),
                    _buildToggleRow(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _initialize,
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder:
                              (context, index) =>
                                  _buildExpenseTile(expenses[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSummary(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryColumn(
            title: "Total Expenses",
            value: expenseProvider.totalExpense.toString(),
          ),
          Container(
            height: 50,
            width: 1,
            color: const Color(0xffe8e8e8).withOpacity(0.2),
          ),
          _buildSummaryColumn(
            title: "This Month",
            value: expenseProvider.totalExpenseThisMonth.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyles.subBodyText(Colors.white)),
            const SizedBox(width: 10),
            const Icon(Icons.money_sharp, color: Colors.white, size: 15),
          ],
        ),
        Text(
          formatIndianShort(double.parse(value)),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _toggleViewAll,
          child: Text(
            !viewAll ? "This Week" : "View All",
            style: AppTextStyles.bodyTitleText(AppColors.grey800Color),
          ),
        ),
        GestureDetector(
          onTap: _toggleViewAll,
          child: Text(
            !viewAll ? "View all" : "This Week",
            style: AppTextStyles.bodySmallSemiBoldText(AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  void _toggleViewAll() => setState(() => viewAll = !viewAll);

  Widget _buildExpenseTile(expense) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wallet,
                        color: AppColors.grey800Color,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.name ?? '',
                          style: AppTextStyles.bodyText(AppColors.grey800Color),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "₹${expense.amount}",
                          style: AppTextStyles.bodyText(AppColors.errorColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          expense.description ?? '',
                          style: AppTextStyles.bodyText(AppColors.grey800Color),
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                formatDate(expense.date),
                style: AppTextStyles.bodyText(AppColors.grey800Color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: () => _onEditExpense(expense),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  onTap: () => _showMyDialog(expense.id!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.grey800Color),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.bodyText(AppColors.grey800Color)),
          ],
        ),
      ),
    );
  }

  void _onAddExpense() {
    if (currentLibraryId == null) {
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddExpense(),
    );
  }

  void _onEditExpense(expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditExpense(expense: expense),
    );
  }

  Future<void> _showMyDialog(String id) async {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    bool isDeleting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundBlueColor,
              title: Text(
                'Delete Expense',
                style: AppTextStyles.appbarTitleText(AppColors.primaryColor),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'This Expense will be deleted',
                      style: AppTextStyles.bodyText(Colors.black),
                    ),
                    Text(
                      'Would you like to delete this expense?',
                      style: AppTextStyles.bodyText(Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                isDeleting
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.errorColor,
                          ),
                        ),
                      ),
                    )
                    : TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                      onPressed: () async {
                        setState(() => isDeleting = true);
                        await expenseProvider.deleteexpense(
                          id,
                          currentLibraryId!,
                        );
                        setState(() => isDeleting = false);
                        if (!mounted) return;
                        AppSnackbar.showSnackbar(
                          context,
                          'Expense deleted successfully',
                          AppColors.errorColor,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
