import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/models/plan_model.dart';
import 'package:lib_app/models/seat_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/screens/inovice/preview_invoice.dart';
import 'package:lib_app/utils/Drop_down_text_field.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/date_picker.dart';
import 'package:lib_app/utils/date_picker_text_field.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMember extends StatefulWidget {
  final String? seatId;
  const AddMember({super.key, this.seatId});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _customDaysController = TextEditingController();
  String? _selectedGender;
  final _dobController = TextEditingController();
  bool _isPlanSelected = false;
  bool _isReservedSeat = true;
  PlanModel? _selectedPlan;
  final _planStartDateController = TextEditingController();
  final _planEndDateController = TextEditingController();
  final _seatIdController = TextEditingController();
  String? currentLibraryId;
  final _amountPaidController = TextEditingController();
  final _amountDueController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  List<String> _availableSeats = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted) return;
    if (currentLibraryId == null) {
      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "No library selected. Please select a library first.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.errorColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    await planProvider.loadPlans(currentLibraryId!);
    if (planProvider.plans.isEmpty) {
      if (!mounted) return;
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "No plans available (add plans in app drawer)",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.errorColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!mounted) return;
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    await seatProvider.loadseats(currentLibraryId!);
    if (seatProvider.availableSeats.isEmpty) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "No seats available (add seats in library management)",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.errorColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    _idController.text =
        await Provider.of<MemberProvider>(
          context,
          listen: false,
        ).getlastMemberId();
    _availableSeats =
        seatProvider.availableSeats.map((seat) => seat.seatId!).toList();
    _seatIdController.text = widget.seatId ?? _availableSeats.first;
    setState(() => _isLoading = false);
  }

  Future<void> addMemberData() async {
    setState(() => _isLoading = true);
    if (_idController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedGender == null ||
        _selectedPlan == null ||
        _planStartDateController.text.isEmpty ||
        _planEndDateController.text.isEmpty ||
        _seatIdController.text.isEmpty) {
      AppSnackbar.showSnackbar(
        context,
        'Please fill all the required fields',
        AppColors.errorColor,
      );
      setState(() => _isLoading = false);
      return;
    }

    final invoice = InvoiceModel(
      memberId: _idController.text,
      libraryId: currentLibraryId,
      date: DateTime.now(),
      startDate: DateFormat('dd-MM-yyyy').parse(_planStartDateController.text),
      endDate: DateFormat('dd-MM-yyyy').parse(_planEndDateController.text),
      plan: _selectedPlan,
      total: _selectedPlan?.price?.toDouble(),
      amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
      amountDue: double.tryParse(_amountDueController.text) ?? 0.0,
      paymentMethod: _paymentMethodController.text,
      memberName: _nameController.text,
      memberPhone: _phoneController.text,
      seatId: _isReservedSeat ? _seatIdController.text : "Rotational Seat",
    );

    final invoiceId = await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).addinvoice(currentLibraryId!, invoice);
    invoice.id = invoiceId;

    final member = MemberModel(
      id: _idController.text,
      name: _nameController.text,
      libraryId: currentLibraryId,
      seatId: _isReservedSeat ? _seatIdController.text : "Rotational Seat",
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text,
      address:
          _addressController.text.isNotEmpty ? _addressController.text : null,
      dateOfBirth:
          _dobController.text.isNotEmpty
              ? DateFormat('dd-MM-yyyy').parse(_dobController.text)
              : null,
      gender: _selectedGender,
      dateOfJoining: DateTime.now(),
      isActive: true,
      isReserved: _isReservedSeat,
      paymentStatus: 'Paid',
      amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
      amountDue: double.tryParse(_amountDueController.text) ?? 0.0,
      totalAmount: _selectedPlan!.price?.toDouble(),
      currentPlan: _selectedPlan,
      planStartDate: DateFormat(
        'dd-MM-yyyy',
      ).parse(_planStartDateController.text),
      planEndDate: DateFormat('dd-MM-yyyy').parse(_planEndDateController.text),
      invoices: [invoiceId],
    );
    if (!mounted) return;
    await Provider.of<MemberProvider>(
      context,
      listen: false,
    ).addmember(member, currentLibraryId!);

    if (_isReservedSeat) {
      final seatId = _seatIdController.text;
      String? series;
      int? seatNumber;
      if (seatId.contains('_')) {
        var parts = seatId.split('_');
        if (parts.length == 2) {
          series = parts[0];
          seatNumber = int.tryParse(parts[1]);
        }
      }
      final seat = SeatModel(
        seatId: seatId,
        seatNumber: seatNumber,
        series: series,
        isBooked: true,
        memberId: member.id,
        expirationDate: DateFormat(
          'dd-MM-yyyy',
        ).parse(_planEndDateController.text),
        isNoticed: false,
      );
      if (!mounted) return;
      await Provider.of<SeatProvider>(
        context,
        listen: false,
      ).updateseat(currentLibraryId!, seat);
    }
    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Member added successfully',
      AppColors.successColor,
    );
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(invoiceData: invoice),
      ),
    );
  }

  Widget _buildGenderField() {
    return FormField<String>(
      validator:
          (value) => _selectedGender == null ? 'Please select a gender' : null,
      builder:
          (formFieldState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Gender :',
                    style: AppTextStyles.subBodyText(AppColors.grey500Color),
                  ),
                  const SizedBox(width: 10),
                  ...['Male', 'Female'].map(
                    (gender) => Row(
                      children: [
                        Radio<String>(
                          fillColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          value: gender,
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() => _selectedGender = value!);
                            formFieldState.didChange(value);
                          },
                        ),
                        Text(
                          gender,
                          style: AppTextStyles.subBodyText(
                            AppColors.grey500Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (formFieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    formFieldState.errorText ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildSeatTypeField() {
    return Row(
      children: [
        Text(
          'Seat Type :',
          style: AppTextStyles.subBodyText(AppColors.grey500Color),
        ),
        const SizedBox(width: 10),
        ...[
          {'label': 'Reserved', 'value': true},
          {'label': 'Rotational', 'value': false},
        ].map(
          (type) => Row(
            children: [
              Radio<bool>(
                fillColor: MaterialStateProperty.all(AppColors.primaryColor),
                value: type['value'] as bool,
                groupValue: _isReservedSeat,
                onChanged: (value) {
                  setState(() {
                    _isReservedSeat = value!;
                    _isPlanSelected = false;
                    _selectedPlan = null;
                  });
                },
              ),
              Text(
                type['label'] as String,
                style: AppTextStyles.subBodyText(AppColors.grey500Color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanDropdown() {
    final planProvider = Provider.of<PlanProvider>(context);
    final plans =
        _isReservedSeat
            ? planProvider.reservedSeatPlans
            : planProvider.unreservedSeatPlans;
    return DropDownTextField(
      hintText: "Select Plan",
      Item:
          plans
              .map(
                (plan) => DropdownMenuItem<PlanModel>(
                  value: plan,
                  child: Text(plan.name!, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      value: _selectedPlan,
      validator: (value) => value == null ? 'Please select a plan' : null,
      onChanged: (value) {
        setState(() {
          _selectedPlan = value;
          _isPlanSelected = true;
          _customDaysController.text =
              _selectedPlan!.duration?.toString() ?? '';
          _totalAmountController.text = _selectedPlan!.price?.toString() ?? '';
        });
      },
    );
  }

  Widget _buildPlanDetails() {
    if (!_isPlanSelected) return const SizedBox();
    return Column(
      children: [
        const SizedBox(height: 16),
        DatePickerTextField(
          controller: _planStartDateController,
          hintText: 'Plan Start Date',
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Please select a plan start date'
                      : null,
          onTap: () async {
            DateTime? pickedDate = await showAppDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
            );
            if (pickedDate != null) {
              setState(() {
                _planStartDateController.text = formatDate(pickedDate);
                _planEndDateController.text = formatDate(
                  pickedDate.add(Duration(days: _selectedPlan!.duration! - 1)),
                );
              });
            }
          },
        ),
        const SizedBox(height: 16),
        CustomLLabelTextField(
          controller: _customDaysController,
          hintText: 'Customize Days',
          keyboardType: TextInputType.number,
          validator: validateIntField,
          onChanged: (value) {
            if (_planStartDateController.text.isNotEmpty && value.isNotEmpty) {
              final startDate = DateFormat(
                'dd-MM-yyyy',
              ).parse(_planStartDateController.text);
              final customDays = int.tryParse(value) ?? 0;
              if (customDays > 0) {
                final endDate = startDate.add(Duration(days: customDays - 1));
                _planEndDateController.text = formatDate(endDate);
              }
            }
          },
        ),
        const SizedBox(height: 16),
        CustomLLabelTextField(
          controller: _planEndDateController,
          hintText: 'Plan End Date',
          readOnly: true,
          suffixIcon: Icons.calendar_today,
        ),
        const SizedBox(height: 16),
        CustomLLabelTextField(
          controller: _totalAmountController,
          hintText: 'Total Amount',
          keyboardType: TextInputType.number,
          validator: validateDoubleField,
        ),
        const SizedBox(height: 16),
        CustomLLabelTextField(
          controller: _amountPaidController,
          hintText: 'Amount Paid',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount number';
            }
            final paid = double.tryParse(value);
            final total = double.tryParse(_totalAmountController.text) ?? 0.0;
            if (paid == null) return 'Please enter a valid number';
            if (paid > total) {
              return 'Please enter an amount less than or equal to $total';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              final total = double.tryParse(_totalAmountController.text) ?? 0.0;
              final paid = double.tryParse(value) ?? 0.0;
              _amountDueController.text = (total - paid).toString();
            });
          },
        ),
        const SizedBox(height: 16),
        CustomLLabelTextField(
          readOnly: true,
          controller: _amountDueController,
          hintText: 'Amount Due',
        ),
        const SizedBox(height: 16),
        DropDownTextField(
          hintText: 'Payment Method',
          value: null,
          Item:
              ['Cash', 'Card', 'Online', 'Both Cash & Online']
                  .map(
                    (method) => DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => setState(() => _paymentMethodController.text = value!),
          validator:
              (value) =>
                  value == null ? 'Please select a payment method' : null,
        ),
      ],
    );
  }

  Widget _buildSeatDropdown() {
    if (!_isReservedSeat) return const SizedBox();
    return DropDownTextField(
      hintText: "Select Seat",
      value: _seatIdController.text,
      Item:
          _availableSeats
              .map(
                (seat) =>
                    DropdownMenuItem<String>(value: seat, child: Text(seat)),
              )
              .toList(),
      onChanged: (value) => setState(() => _seatIdController.text = value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Add Member'),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _idController,
                          hintText: 'Member ID',
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _nameController,
                          hintText: 'Member Name',
                          keyboardType: TextInputType.name,
                          validator: validateName,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _emailController,
                          hintText: 'Email (optional)',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _phoneController,
                          hintText: 'Phone',
                          keyboardType: TextInputType.phone,
                          validator: validatePhone,
                        ),
                        const SizedBox(height: 16),
                        CustomLLabelTextField(
                          controller: _addressController,
                          hintText: 'Address (Optional)',
                          keyboardType: TextInputType.streetAddress,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        _buildGenderField(),
                        const SizedBox(height: 16),
                        DatePickerTextField(
                          controller: _dobController,
                          hintText: 'Date of Birth (optional)',
                          onTap: () async {
                            DateTime? pickedDate = await showAppDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(
                                () =>
                                    _dobController.text = formatDate(
                                      pickedDate,
                                    ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSeatTypeField(),
                        const SizedBox(height: 16),
                        _buildPlanDropdown(),
                        _buildPlanDetails(),
                        const SizedBox(height: 16),
                        _buildSeatDropdown(),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Add Member',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              addMemberData();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
