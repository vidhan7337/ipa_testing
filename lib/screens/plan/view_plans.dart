import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/screens/plan/add_plan.dart';
import 'package:lib_app/screens/plan/edit_plan.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewPlans extends StatefulWidget {
  const ViewPlans({super.key});

  @override
  State<ViewPlans> createState() => _ViewPlansState();
}

class _ViewPlansState extends State<ViewPlans> {
  String? currentLibraryId;
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
      setState(() => isLoading = false);
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      return;
    }
    await Provider.of<PlanProvider>(
      context,
      listen: false,
    ).loadPlans(currentLibraryId!);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    return Scaffold(
      appBar: AppAppBar(title: 'View Plans'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _onAddPlanPressed,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : planProvider.plans.isEmpty
              ? Center(
                child: Text(
                  'No Plans Available',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: RefreshIndicator(
                  onRefresh: _initialize,
                  child: ListView.builder(
                    itemCount: planProvider.plans.length,
                    itemBuilder: (context, index) {
                      final plan = planProvider.plans[index];
                      return _PlanCard(
                        plan: plan,
                        onEdit:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPlan(plan: plan),
                              ),
                            ),
                        onDelete: () => _showDeleteDialog(plan.id!),
                      );
                    },
                  ),
                ),
              ),
    );
  }

  void _onAddPlanPressed() {
    if (currentLibraryId == null) {
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlan()),
    );
  }

  Future<void> _showDeleteDialog(String id) async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    bool isDeleting = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: AppColors.backgroundBlueColor,
                  title: Text(
                    'Delete Plan',
                    style: AppTextStyles.appbarTitleText(
                      AppColors.primaryColor,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text(
                          'This Plan will be deleted',
                          style: AppTextStyles.bodyText(Colors.black),
                        ),
                        Text(
                          'Would you like to delete this plan?',
                          style: AppTextStyles.bodyText(Colors.black),
                        ),
                      ],
                    ),
                  ),
                  actions: [
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
                            await planProvider.deletePlan(
                              currentLibraryId!,
                              id,
                            );
                            if (mounted) {
                              AppSnackbar.showSnackbar(
                                context,
                                'Plan deleted successfully',
                                AppColors.errorColor,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
          ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final dynamic plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x0D000000), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xffe6e8f6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Icon(
                    size: 15,
                    Icons.calendar_month,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.name ?? '',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Color(0x0D000000), thickness: 1),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                _PlanDetailRow(
                  label: "• Seat Type",
                  value: plan.isReserved == true ? "Reserved" : "Rotating",
                ),
                const SizedBox(height: 10),
                _PlanDetailRow(label: "• Amount", value: "₹${plan.price}"),
                const SizedBox(height: 10),
                _PlanDetailRow(
                  label: "• Duration",
                  value: "${plan.duration} days",
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "Edit",
                  icon: const Icon(Icons.edit, color: Colors.white, size: 15),
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: "Delete",
                  icon: const Icon(Icons.delete, color: Colors.white, size: 15),
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _PlanDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.subHeading(AppColors.grey800Color)),
        Text(value, style: AppTextStyles.subBodyText(AppColors.grey900Color)),
      ],
    );
  }
}
