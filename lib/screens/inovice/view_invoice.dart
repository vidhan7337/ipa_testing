import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/invoice_model.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/screens/inovice/edit_inovice.dart';
import 'package:lib_app/screens/inovice/preview_invoice.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:lib_app/widgets/inovice_view_down_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewInvoices extends StatefulWidget {
  const ViewInvoices({super.key});

  @override
  State<ViewInvoices> createState() => _ViewInvoicesState();
}

class _ViewInvoicesState extends State<ViewInvoices> {
  late String currentLibraryId;
  final searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLibraryAndInvoices();
  }

  Future<void> _loadLibraryAndInvoices() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final libraryId = prefs.getString('currentLibraryId');
    if (libraryId == null) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      return;
    }
    currentLibraryId = libraryId;
    if (!mounted) return;
    await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).loadinvoices(currentLibraryId);
    setState(() {
      isLoading = false;
    });
  }

  List<InvoiceModel> _filterInvoices(List<InvoiceModel> invoices) {
    if (_searchQuery.isEmpty) return invoices;
    final query = _searchQuery.toLowerCase();
    return invoices.where((invoice) {
      return (invoice.id ?? '').toLowerCase().contains(query) ||
          (invoice.memberId ?? '').toLowerCase().contains(query) ||
          (invoice.seatId ?? '').toLowerCase().contains(query) ||
          (invoice.memberName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: 'View Invoices'),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, _) {
          final filteredInvoices = _filterInvoices(invoiceProvider.invoices);
          if (invoiceProvider.invoices.isEmpty) {
            return const Center(
              child: Text(
                'No Invoices Available',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: RefreshIndicator(
              onRefresh: _loadLibraryAndInvoices,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomLLabelTextField(
                      icon: Icons.search,
                      controller: searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      hintText: 'Search Inovices',
                      suffixIcon: Icons.filter_list,
                      onSuffixIconPressed: () {
                        // Add filter logic here if needed
                      },
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = filteredInvoices[index];
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0x0d000000),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.5,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppTextSpan(
                                              title: "Invoice ID",
                                              value: invoice.id.toString(),
                                            ),
                                            AppTextSpan(
                                              title: "Date",
                                              value:
                                                  "${invoice.date!.day.toString().padLeft(2, '0')}/${invoice.date!.month.toString().padLeft(2, '0')}/${invoice.date!.year}",
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color(0x0d000000),
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Mem ID: ${invoice.memberId}",
                                            style:
                                                AppTextStyles.bodySmallSemiBoldText(
                                                  AppColors.grey800Color,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: const Color(0x0D000000),
                                  ),
                                  const SizedBox(height: 10),
                                  AppTextSpan(
                                    title: "Name",
                                    value: invoice.memberName ?? '',
                                  ),
                                  AppTextSpan(
                                    title: "Seat ID",
                                    value: invoice.seatId ?? '',
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: const Color(0x0D000000),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppTextSpan(
                                              title: "Payment Mode",
                                              value:
                                                  invoice.paymentMethod ?? '',
                                            ),
                                            AppTextSpan(
                                              title: "Start Date",
                                              value: formatDate(
                                                invoice.startDate!,
                                              ),
                                            ),
                                            AppTextSpan(
                                              title: "End Date",
                                              value: formatDate(
                                                invoice.endDate!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppTextSpan(
                                              title: "Total Amt",
                                              value: formatIndianShort(
                                                invoice.total!,
                                              ),
                                            ),
                                            AppTextSpan(
                                              title: "Paid Amt",
                                              value: formatIndianShort(
                                                invoice.amountPaid!,
                                              ),
                                            ),
                                            AppTextSpan(
                                              title: "Due Amt",
                                              value: formatIndianShort(
                                                invoice.amountDue!,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: const Color(0x0D000000),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      InoviceViewDownContainer(
                                        title: "View",
                                        icon: Icons.remove_red_eye,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => PdfPreviewPage(
                                                    invoiceData: invoice,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      InoviceViewDownContainer(
                                        title: "Edit",
                                        icon: Icons.edit,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => EditInovice(
                                                    invoiceModel: invoice,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
