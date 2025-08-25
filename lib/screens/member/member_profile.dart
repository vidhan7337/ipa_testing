import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/screens/inovice/edit_inovice.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberProfile extends StatefulWidget {
  final MemberModel? memberModel;
  const MemberProfile({required this.memberModel, super.key});

  @override
  State<MemberProfile> createState() => _MemberProfileState();
}

class _MemberProfileState extends State<MemberProfile> {
  String? currentLibraryId;
  List<InvoiceModel> invoices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted) return;
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    await invoiceProvider.loadinvoices(currentLibraryId!);
    invoices = invoiceProvider.inovicesByMemberId(widget.memberModel!.id ?? '');
    if (mounted) setState(() => isLoading = false);
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x0d000000), width: 1),
      ),
      child: Center(
        child: Text(
          title,
          style:
              color == null
                  ? AppTextStyles.bodySmallSemiBoldText(AppColors.grey800Color)
                  : AppTextStyles.bodyText(Colors.white),
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Expanded(child: Container(height: 1, color: const Color(0x0D000000)));

  Widget _buildMemberInfo() {
    final m = widget.memberModel!;
    return Container(
      width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/editImage.png'),
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0x0d000000), width: 2),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Member ID: ${m.id}"),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: AppTextSpan(title: 'Name', value: m.name!),
                  ),
                  AppTextSpan(title: 'Seat No', value: m.seatId!),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [_buildSectionTitle("Contact Info"), _buildDivider()]),
          const SizedBox(height: 10),
          AppTextSpan(title: 'Gender', value: m.gender!),
          if (m.email != null) AppTextSpan(title: 'Email', value: m.email!),
          if (m.address != null)
            AppTextSpan(title: 'Address', value: m.address!),
          AppTextSpan(title: 'Phone', value: m.phone!),
          const SizedBox(height: 10),
          Row(
            children: [_buildSectionTitle("Membership Info"), _buildDivider()],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextSpan(title: "Plan", value: m.currentPlan!.name!),
                    AppTextSpan(
                      title: "Join Date",
                      value: formatDate(m.dateOfJoining!),
                    ),
                    AppTextSpan(
                      title: "End Date",
                      value: formatDate(m.planEndDate!),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextSpan(
                      title: "Total Amt",
                      value: formatIndianShort(m.totalAmount!),
                    ),
                    AppTextSpan(
                      title: "Paid Amt",
                      value: formatIndianShort(m.amountPaid!),
                    ),
                    AppTextSpan(
                      title: "Due Amt",
                      value: formatIndianShort(m.amountDue!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(InvoiceModel invoice) {
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
              _buildSectionTitle("Date: ${formatDate(invoice.date!)}"),
              _buildDivider(),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditInovice(invoiceModel: invoice),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.grey300Color, width: 1),
                  ),
                  child: Icon(
                    Icons.edit_document,
                    size: 16,
                    color: AppColors.grey600Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppTextSpan(title: "Invoice ID", value: invoice.id.toString()),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0x0D000000),
          ),
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
                      value: invoice.paymentMethod!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'Member Profile'),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildMemberInfo(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildDivider(),
                        _buildSectionTitle(
                          "Invoices",
                          color: AppColors.primaryColor,
                        ),
                        _buildDivider(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoices.length,
                      itemBuilder:
                          (context, index) =>
                              _buildInvoiceItem(invoices[index]),
                    ),
                  ],
                ),
              ),
    );
  }
}
