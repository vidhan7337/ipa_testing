import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/Functions/validators.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/utils/Drop_down_text_field.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/date_picker.dart';
import 'package:lib_app/utils/date_picker_text_field.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EditInovice extends StatefulWidget {
  final InvoiceModel invoiceModel;
  const EditInovice({super.key, required this.invoiceModel});

  @override
  State<EditInovice> createState() => _EditInoviceState();
}

class _EditInoviceState extends State<EditInovice> {
  final _formKey = GlobalKey<FormState>();
  final _memberIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _seatNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _amountTotalController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _amountDueController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  String? currentLibraryId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    final invoice = widget.invoiceModel;
    _memberIdController.text = invoice.memberId ?? '';
    _nameController.text = invoice.memberName ?? '';
    _dateController.text = formatDate(invoice.date);
    _seatNoController.text = invoice.seatId ?? '';
    _phoneController.text = invoice.memberPhone ?? '';
    _startDateController.text = formatDate(invoice.startDate);
    _endDateController.text = formatDate(invoice.endDate);
    _amountTotalController.text = invoice.total?.toString() ?? '';
    _amountPaidController.text = invoice.amountPaid?.toString() ?? '';
    _amountDueController.text = invoice.amountDue?.toString() ?? '';
    _paymentMethodController.text = invoice.paymentMethod ?? '';
    setState(() => isLoading = false);
  }

  Future<void> _editInvoice() async {
    setState(() => isLoading = true);
    final invoice =
        widget.invoiceModel
          ..memberName = _nameController.text
          ..memberPhone = _phoneController.text
          ..startDate = DateFormat(
            'dd-MM-yyyy',
          ).parse(_startDateController.text)
          ..endDate = DateFormat('dd-MM-yyyy').parse(_endDateController.text)
          ..total = double.parse(_amountTotalController.text)
          ..amountPaid = double.parse(_amountPaidController.text)
          ..amountDue = double.parse(_amountDueController.text)
          ..paymentMethod = _paymentMethodController.text;

    await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).updateinvoice(currentLibraryId!, invoice);

    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Invoice updated successfully',
      AppColors.successColor,
    );
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _memberIdController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _seatNoController.dispose();
    _phoneController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _amountTotalController.dispose();
    _amountPaidController.dispose();
    _amountDueController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Edit Invoice: ${widget.invoiceModel.id}'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : RefreshIndicator(
                onRefresh: _initializeFields,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomLLabelTextField(
                            controller: _memberIdController,
                            hintText: 'Member Id',
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
                            controller: _phoneController,
                            hintText: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            validator: validatePhone,
                          ),
                          const SizedBox(height: 16),
                          CustomLLabelTextField(
                            controller: _seatNoController,
                            hintText: 'Seat No',
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          DatePickerTextField(
                            hintText: "Start Date",
                            controller: _startDateController,
                            onTap: () async {
                              DateTime? pickedDate = await showAppDatePicker(
                                context: context,
                                initialDate: widget.invoiceModel.startDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                _startDateController.text = formatDate(
                                  pickedDate,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DatePickerTextField(
                            hintText: "End Date",
                            controller: _endDateController,
                            onTap: () async {
                              DateTime? pickedDate = await showAppDatePicker(
                                context: context,
                                initialDate: widget.invoiceModel.endDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                _endDateController.text = formatDate(
                                  pickedDate,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomLLabelTextField(
                            controller: _amountTotalController,
                            hintText: 'Total Amount',
                            keyboardType: TextInputType.number,
                            validator: validateDoubleField,
                          ),
                          const SizedBox(height: 16),
                          CustomLLabelTextField(
                            controller: _amountPaidController,
                            hintText: "Amount Paid",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final total =
                                  double.tryParse(
                                    _amountTotalController.text,
                                  ) ??
                                  0;
                              final paid = double.tryParse(value ?? '') ?? -1;
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount number';
                              } else if (paid < 0) {
                                return 'Paid amount cannot be negative';
                              } else if (paid > total) {
                                return 'Paid amount cannot be greater than total amount';
                              } else if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomLLabelTextField(
                            controller: _amountDueController,
                            hintText: 'Amount Due',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final total =
                                  double.tryParse(
                                    _amountTotalController.text,
                                  ) ??
                                  0;
                              final paid =
                                  double.tryParse(_amountPaidController.text) ??
                                  0;
                              final due = double.tryParse(value ?? '') ?? -1;
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount number';
                              } else if (due < 0) {
                                return 'Paid amount cannot be negative';
                              } else if (due > total) {
                                return 'Paid amount cannot be greater than total amount';
                              } else if (due != total - paid) {
                                return 'Entered amount due is not valid';
                              } else if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropDownTextField(
                            hintText: 'Payment Method',
                            value:
                                _paymentMethodController.text.isNotEmpty
                                    ? _paymentMethodController.text
                                    : null,
                            Item:
                                ['Cash', 'Card', 'Online', 'Both Cash & Online']
                                    .map(
                                      (method) => DropdownMenuItem<String>(
                                        value: method,
                                        child: Text(method),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              _paymentMethodController.text = value!;
                            },
                            validator:
                                (value) =>
                                    value == null
                                        ? 'Please select a payment method'
                                        : null,
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: 'Edit Invoice',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _editInvoice();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
