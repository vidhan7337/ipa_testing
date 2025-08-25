import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/screens/member/payment_details.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPayment extends StatefulWidget {
  final MemberModel memberModel;
  const AddPayment({super.key, required this.memberModel});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  String? currentLibraryId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted || currentLibraryId == null) return;
    await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).loadinvoices(currentLibraryId!);
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final invoices = invoiceProvider.inovicesByMemberId(
      widget.memberModel.id ?? '',
    )..sort((b, a) => a.date!.compareTo(b.date!));

    return Scaffold(
      appBar: const AppAppBar(title: 'Add Payment'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : RefreshIndicator(
                onRefresh: _loadInvoices,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return _InvoiceCard(
                      invoice: invoice,
                      memberModel: widget.memberModel,
                    );
                  },
                ),
              ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final MemberModel memberModel;

  const _InvoiceCard({required this.invoice, required this.memberModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border.all(color: const Color(0x0d000000), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x0d000000), width: 1),
                ),
                child: Center(
                  child: Text(
                    "Date: ${formatDate(invoice.date!)}",
                    style: AppTextStyles.bodySmallSemiBoldText(
                      AppColors.grey800Color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Divider(color: Color(0x0D000000), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppTextSpan(title: "Invoice ID", value: invoice.id.toString()),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0D000000), thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextSpan(
                      title: "Total Amt",
                      value: formatIndianShort(invoice.total!),
                    ),
                    AppTextSpan(
                      title: "Paid Amt",
                      value: formatIndianShort(invoice.amountPaid!),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextSpan(
                      title: "Due Amt",
                      value: formatIndianShort(invoice.amountDue!),
                    ),
                    AppTextSpan(
                      title: "Payment Mode",
                      value: invoice.paymentMethod ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          invoice.amountDue == 0
              ? Center(
                child: Text(
                  'Paid',
                  style: AppTextStyles.bodyTitleText(AppColors.successColor),
                ),
              )
              : GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder:
                        (context) => PaymentDetails(
                          invoice: invoice,
                          memberModel: memberModel,
                        ),
                  );
                },
                child: Center(
                  child: Text(
                    'Add payment',
                    style: AppTextStyles.bodyTitleText(AppColors.errorColor),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
