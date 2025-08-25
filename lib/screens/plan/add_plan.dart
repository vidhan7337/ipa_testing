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

class AddPlan extends StatefulWidget {
  const AddPlan({super.key});

  @override
  State<AddPlan> createState() => _AddPlanState();
}

class _AddPlanState extends State<AddPlan> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isReservedSelected = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> addPlanData() async {
    setState(() => isLoading = true);
    try {
      final name = _nameController.text.trim();
      final price = int.tryParse(_priceController.text.trim());
      final duration = int.tryParse(_durationController.text.trim());

      final plan = PlanModel(
        name: name,
        price: price,
        duration: duration,
        isReserved: _isReservedSelected,
      );

      final prefs = await SharedPreferences.getInstance();
      final currentLibraryId = prefs.getString('currentLibraryId');
      if (!mounted) return;
      if (currentLibraryId == null) {
        AppSnackbar.showSnackbar(
          context,
          'No library selected',
          AppColors.errorColor,
        );
        return;
      }

      Provider.of<PlanProvider>(
        context,
        listen: false,
      ).addPlan(currentLibraryId, plan);

      AppSnackbar.showSnackbar(
        context,
        'Plan added successfully',
        AppColors.successColor,
      );

      _nameController.clear();
      _priceController.clear();
      _durationController.clear();
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Add Plan'),
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
                    hintText: 'Enter Duration (in days)',
                    icon: Icons.timer,
                    keyboardType: TextInputType.number,
                    validator: validateIntField,
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                      : AppButton(
                        text: 'Add Plan',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            addPlanData();
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.white,
                        ),
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
