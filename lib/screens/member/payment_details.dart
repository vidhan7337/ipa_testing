import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/utils/Drop_down_text_field.dart';
import 'package:lib_app/utils/button.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentDetails extends StatefulWidget {
  final InvoiceModel? invoice;
  final MemberModel? memberModel;
  const PaymentDetails({
    super.key,
    required this.invoice,
    required this.memberModel,
  });

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  final _amountController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  String? currentLibraryId;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    _amountController.text = widget.invoice?.amountDue?.toString() ?? '';
    setState(() => isLoading = false);
  }

  Future<void> addPayment() async {
    setState(() => isLoading = true);

    if (_amountController.text.isEmpty ||
        _paymentMethodController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select payment method",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: AppColors.errorColor,
        textColor: Colors.white,
      );
      setState(() => isLoading = false);
      return;
    }

    final amount = double.parse(_amountController.text);

    widget.invoice!
      ..amountPaid = amount + (widget.invoice!.amountPaid ?? 0)
      ..amountDue = (widget.invoice!.amountDue ?? 0) - amount
      ..paymentMethod = _paymentMethodController.text;

    final invoiceProvider = context.read<InvoiceProvider>();
    await invoiceProvider.updateinvoice(currentLibraryId!, widget.invoice!);

    widget.memberModel!
      ..amountPaid = amount + (widget.memberModel!.amountPaid ?? 0)
      ..amountDue = (widget.memberModel!.amountDue ?? 0) - amount;
    if (!mounted) return;
    final memberProvider = context.read<MemberProvider>();
    await memberProvider.updatemember(widget.memberModel!, currentLibraryId!);

    if (!mounted) return;
    AppSnackbar.showSnackbar(
      context,
      'Payment added successfully',
      AppColors.successColor,
    );
    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Add Payment",
                style: AppTextStyles.bodyTitleText(AppColors.grey800Color),
              ),
              const SizedBox(height: 16),
              CustomLLabelTextField(
                controller: _amountController,
                hintText: "Amount",
                keyboardType: TextInputType.number,
                readOnly: false,
                validator: (value) {
                  final amountDue = widget.invoice?.amountDue ?? 0;
                  final parsed = double.tryParse(value ?? '');
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount number';
                  } else if (parsed == null) {
                    return 'Please enter a valid number';
                  } else if (parsed > amountDue || parsed < 0) {
                    return 'Please enter an amount less than or equal to $amountDue';
                  }
                  return null;
                },
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
                onChanged: (value) {
                  setState(() {
                    _paymentMethodController.text = value ?? '';
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select a payment method' : null,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                  : AppButton(
                    text: 'Add Payment',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addPayment();
                      }
                    },
                  ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
