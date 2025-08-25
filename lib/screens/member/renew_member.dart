import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class RenewMember extends StatefulWidget {
  final MemberModel? memberData;
  const RenewMember({super.key, required this.memberData});

  @override
  State<RenewMember> createState() => _RenewMemberState();
}

class _RenewMemberState extends State<RenewMember> {
  bool _isPlanSelected = false;
  PlanModel? _selectedPlan;
  final _idController = TextEditingController();
  final _planStartDateController = TextEditingController();
  final _customDaysController = TextEditingController();
  bool _isReservedSeat = false;
  final _planEndDateController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _amountDueController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _seatIdController = TextEditingController();
  final _totalAmountController = TextEditingController();
  List<String> _availableSeats = [];
  List<PlanModel> _plans = [];
  String? currentLibraryId;
  String? currentUserId;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (!mounted) return;
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);

    await Future.wait([
      planProvider.loadPlans(currentLibraryId!),
      seatProvider.loadseats(currentLibraryId!),
    ]);

    _availableSeats =
        seatProvider.availableSeats.map((seat) => seat.seatId!).toList();
    _idController.text = widget.memberData!.id.toString();
    _isReservedSeat = widget.memberData!.isReserved ?? false;

    if (widget.memberData?.isActive != false) {
      _seatIdController.text = widget.memberData?.seatId ?? '';
      if (!_availableSeats.contains(widget.memberData?.seatId)) {
        _availableSeats.add(widget.memberData?.seatId ?? '');
      }
      _plans = planProvider.plans;
      final plan = _plans.firstWhere(
        (p) => p.id == widget.memberData!.currentPlan?.id,
        orElse: () => _plans.isNotEmpty ? _plans.first : PlanModel(),
      );
      if (plan.id != null) {
        _selectedPlan = plan;
        _customDaysController.text = _selectedPlan!.duration.toString();
        _totalAmountController.text = _selectedPlan!.price.toString();
        _isPlanSelected = true;
        final now = DateTime.now();
        final planEndDate = widget.memberData!.planEndDate!;
        if (planEndDate.isBefore(now)) {
          _planStartDateController.text = formatDate(now);
          _planEndDateController.text = formatDate(
            now.add(Duration(days: _selectedPlan!.duration! - 1)),
          );
        } else {
          _planStartDateController.text = formatDate(planEndDate);
          _planEndDateController.text = formatDate(
            planEndDate.add(Duration(days: _selectedPlan!.duration! - 1)),
          );
        }
      }
    }
    setState(() => isLoading = false);
  }

  Future<void> renewMember() async {
    setState(() => isLoading = true);
    final member = widget.memberData!;
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);

    member
      ..currentPlan = _selectedPlan
      ..isReserved = _isReservedSeat
      ..planStartDate = DateFormat(
        'dd-MM-yyyy',
      ).parse(_planStartDateController.text)
      ..planEndDate = DateFormat(
        'dd-MM-yyyy',
      ).parse(_planEndDateController.text)
      ..amountPaid =
          (member.amountPaid ?? 0) + double.parse(_amountPaidController.text)
      ..amountDue =
          (member.amountDue ?? 0) + double.parse(_amountDueController.text)
      ..totalAmount =
          (member.totalAmount ?? 0) +
          double.parse(_selectedPlan!.price.toString())
      ..isActive = true;

    if (_isReservedSeat) {
      await _handleReservedSeat(member, seatProvider);
    } else {
      await _handleRotationalSeat(member, seatProvider);
    }

    final invoice = InvoiceModel(
      memberId: member.id,
      libraryId: member.libraryId,
      date: DateTime.now(),
      startDate: DateFormat('dd-MM-yyyy').parse(_planStartDateController.text),
      endDate: DateFormat('dd-MM-yyyy').parse(_planEndDateController.text),
      plan: _selectedPlan,
      total: _selectedPlan?.price?.toDouble(),
      amountPaid: double.parse(_amountPaidController.text),
      amountDue: double.parse(_amountDueController.text),
      paymentMethod: _paymentMethodController.text,
      memberName: member.name,
      memberPhone: member.phone,
      seatId: member.seatId,
    );
    if (!mounted) return;
    final invoiceId = await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).addinvoice(member.libraryId!, invoice);
    invoice.id = invoiceId;

    member.invoices = (member.invoices ?? [])..add(invoiceId);
    member.isActive = true;
    if (!mounted) return;
    await Provider.of<MemberProvider>(
      context,
      listen: false,
    ).updatemember(member, member.libraryId!);

    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Member Renewed Successfully',
      AppColors.successColor,
    );
    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(invoiceData: invoice),
      ),
    );
  }

  Future<void> _handleReservedSeat(
    MemberModel member,
    SeatProvider seatProvider,
  ) async {
    final previousSeat = widget.memberData!.seatId;
    final currentSeat = _seatIdController.text;
    member.seatId = currentSeat;
    final fillSeat = SeatModel(
      seatId: currentSeat,
      series: currentSeat.split('_')[0],
      seatNumber: int.tryParse(currentSeat.split('_')[1]),
      memberId: member.id,
      expirationDate: DateFormat(
        'dd-MM-yyyy',
      ).parse(_planEndDateController.text),
      isBooked: true,
      isNoticed: false,
    );
    if (previousSeat != "Rotational Seat") {
      if (previousSeat != currentSeat) {
        final previousSeatModel = SeatModel(
          seatId: previousSeat,
          isBooked: false,
          memberId: null,
          expirationDate: null,
          series: previousSeat?.split('_')[0],
          seatNumber: int.tryParse(previousSeat?.split('_')[1] ?? ''),
          isNoticed: false,
        );
        await seatProvider.updateseat(currentLibraryId!, previousSeatModel);
      }
    }
    await seatProvider.updateseat(currentLibraryId!, fillSeat);
  }

  Future<void> _handleRotationalSeat(
    MemberModel member,
    SeatProvider seatProvider,
  ) async {
    if (widget.memberData!.seatId != "Rotational Seat") {
      final previousSeat = SeatModel(
        seatId: widget.memberData!.seatId,
        isBooked: false,
        memberId: null,
        expirationDate: null,
        series: widget.memberData!.seatId?.split('_')[0],
        seatNumber: int.tryParse(
          widget.memberData!.seatId?.split('_')[1] ?? '',
        ),
        isNoticed: false,
      );
      await seatProvider.updateseat(currentLibraryId!, previousSeat);
    }
    member.seatId = "Rotational Seat";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Renew Member'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
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
                      _buildSeatTypeSelector(),
                      const SizedBox(height: 16),
                      _buildPlanDropdown(),
                      const SizedBox(height: 16),
                      if (_isPlanSelected) ..._buildPlanDetails(),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Renew Member',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            renewMember();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSeatTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Seat Type :',
          style: AppTextStyles.subBodyText(AppColors.grey500Color),
        ),
        const SizedBox(width: 10),
        Row(
          children: [
            Radio<bool>(
              fillColor: MaterialStateProperty.all(AppColors.primaryColor),
              value: true,
              groupValue: _isReservedSeat,
              onChanged: (value) => _onSeatTypeChanged(value!),
            ),
            Text(
              'Reserved',
              style: AppTextStyles.subBodyText(AppColors.grey500Color),
            ),
          ],
        ),
        Row(
          children: [
            Radio<bool>(
              fillColor: MaterialStateProperty.all(AppColors.primaryColor),
              value: false,
              groupValue: _isReservedSeat,
              onChanged: (value) => _onSeatTypeChanged(value!),
            ),
            Text(
              'Rotational',
              style: AppTextStyles.subBodyText(AppColors.grey500Color),
            ),
          ],
        ),
      ],
    );
  }

  void _onSeatTypeChanged(bool value) {
    setState(() {
      _isReservedSeat = value;
      _selectedPlan = null;
      _isPlanSelected = false;
    });
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
                  child: Text(plan.name!),
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

  List<Widget> _buildPlanDetails() {
    return [
      DatePickerTextField(
        controller: _planStartDateController,
        hintText: 'Plan Start Date',
        onTap: () async {
          DateTime? pickedDate = await showAppDatePicker(
            context: context,
            initialDate:
                _planStartDateController.text.isNotEmpty
                    ? DateFormat(
                      'dd-MM-yyyy',
                    ).parse(_planStartDateController.text)
                    : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2050),
          );
          if (pickedDate != null) {
            setState(() {
              _planEndDateController.text = formatDate(
                pickedDate.add(Duration(days: _selectedPlan!.duration! - 1)),
              );
              _planStartDateController.text = formatDate(pickedDate);
            });
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
        controller: _customDaysController,
        hintText: 'Customize Days',
        readOnly: false,
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
        controller: _totalAmountController,
        hintText: 'Total Amount',
        readOnly: false,
        keyboardType: TextInputType.number,
        validator: validateDoubleField,
      ),
      const SizedBox(height: 16),
      CustomLLabelTextField(
        controller: _amountPaidController,
        hintText: 'Amount Paid',
        readOnly: false,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an amount number';
          }
          final paid = double.tryParse(value);
          if (paid == null) return 'Please enter a valid number';
          if (paid > (double.tryParse(_totalAmountController.text) ?? 0)) {
            return 'Please enter an amount less than or equal to ${_totalAmountController.text}';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            _amountDueController.text =
                (double.parse(_totalAmountController.text) -
                        double.parse(value))
                    .toString();
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
            ['Cash', 'Card', 'Online', 'Both Cash & Online'].map((method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
        onChanged:
            (value) => setState(() => _paymentMethodController.text = value!),
        validator:
            (value) => value == null ? 'Please select a payment method' : null,
      ),
      const SizedBox(height: 16),
      if (_isReservedSeat)
        DropDownTextField(
          hintText: "Select Seat",
          value:
              _availableSeats.contains(_seatIdController.text)
                  ? _seatIdController.text
                  : null,
          Item:
              _availableSeats
                  .map(
                    (seat) => DropdownMenuItem<String>(
                      value: seat,
                      child: Text(seat),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _seatIdController.text = value!),
          validator: (value) => value == null ? 'Please select a seat' : null,
        ),
    ];
  }
}
