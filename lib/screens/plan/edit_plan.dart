import 'package:flutter/material.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/plan_model.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/tab_container.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPlan extends StatefulWidget {
  final PlanModel plan;

  const EditPlan({super.key, required this.plan});

  @override
  State<EditPlan> createState() => _EditPlanState();
}

class _EditPlanState extends State<EditPlan> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final String? _planId;
  late bool _isReservedSelected;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name ?? '');
    _priceController = TextEditingController(
      text: widget.plan.price?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.plan.duration?.toString() ?? '',
    );
    _planId = widget.plan.id;
    _isReservedSelected = widget.plan.isReserved ?? true;
  }

  Future<void> editPlanData() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final plan = PlanModel(
      id: _planId,
      name: _nameController.text.trim(),
      price: int.tryParse(_priceController.text.trim()),
      duration: int.tryParse(_durationController.text.trim()),
      isReserved: _isReservedSelected,
    );

    final prefs = await SharedPreferences.getInstance();
    final currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted || currentLibraryId == null) return;

    await Provider.of<PlanProvider>(
      context,
      listen: false,
    ).updatePlan(currentLibraryId, plan);

    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Plan Updated successfully',
      AppColors.successColor,
    );
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Edit Plan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isReservedSelected = true),
                    child: TabContainer(
                      title: "Reserved Seat",
                      isSelected: _isReservedSelected,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isReservedSelected = false),
                    child: TabContainer(
                      title: "Rotating Seat",
                      isSelected: !_isReservedSelected,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomLLabelTextField(
                    controller: _nameController,
                    hintText: 'Enter Plan Name',
                    icon: Icons.title,
                    keyboardType: TextInputType.text,
                    validator: validateName,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _priceController,
                    hintText: 'Enter Price',
                    icon: Icons.money,
                    keyboardType: TextInputType.number,
                    validator: validateDoubleField,
                  ),
                  const SizedBox(height: 16),
                  CustomLLabelTextField(
                    controller: _durationController,
                    hintText: 'Enter Duration',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                    validator: validateIntField,
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      )
                      : AppButton(
                        text: 'Update Plan',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            editPlanData();
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
}
