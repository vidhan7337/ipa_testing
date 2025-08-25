import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/screens/member/add_payment.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:lib_app/widgets/inovice_view_down_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DueReminderMembers extends StatefulWidget {
  const DueReminderMembers({super.key});

  @override
  State<DueReminderMembers> createState() => _DueReminderMembersState();
}

class _DueReminderMembersState extends State<DueReminderMembers> {
  String? currentLibraryId;
  List<MemberModel> membersWithDueAmount = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibraryId();
  }

  Future<void> _loadLibraryId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    setState(() {
      currentLibraryId = prefs.getString('currentLibraryId');
      membersWithDueAmount = memberProvider.membersWithDueAmountList;
      isLoading = false;
    });
  }

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    final Uri whatsapp = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (!await launchUrl(whatsapp, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $whatsapp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Due Reminder Members'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : Consumer<MemberProvider>(
                builder: (context, memberProvider, _) {
                  final membersWithDueAmount =
                      memberProvider.membersWithDueAmountList;
                  if (membersWithDueAmount.isEmpty) {
                    return const Center(
                      child: Text('No members with due amount.'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _loadLibraryId,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: membersWithDueAmount.length,
                      itemBuilder: (context, index) {
                        final member = membersWithDueAmount[index];
                        return _MemberDueCard(
                          member: member,
                          onWhatsApp: () {
                            final phone =
                                "91${member.phone!.replaceAll(" ", "")}";
                            final message =
                                "Hello ${member.name}, your due amount is ₹${member.amountDue}. Kindly clear your payment.";
                            _sendWhatsAppMessage(phone, message);
                          },
                          onPayment: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddPayment(memberModel: member),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}

class _MemberDueCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onWhatsApp;
  final VoidCallback onPayment;

  const _MemberDueCard({
    required this.member,
    required this.onWhatsApp,
    required this.onPayment,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x0d000000), width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(50),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/editImage.png'),
                        fit: BoxFit.contain,
                      ),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.10),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextSpan(title: 'Name', value: member.name!),
                        AppTextSpan(
                          title: 'Seat No',
                          value: member.seatId ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x0d000000), width: 1),
                ),
                child: Center(
                  child: Text(
                    "Mem ID: ${member.id}",
                    style: AppTextStyles.bodySmallSemiBoldText(
                      AppColors.grey800Color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0D000000), height: 1),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextSpan(title: "Phone", value: member.phone!),
                if (member.email != null)
                  AppTextSpan(title: "Email", value: member.email!),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0D000000), height: 1),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextSpan(
                        title: "Plan",
                        value: member.currentPlan!.name!,
                      ),
                      AppTextSpan(
                        title: "Join Date",
                        value: formatDate(member.dateOfJoining!),
                      ),
                      AppTextSpan(
                        title: "End Date",
                        value: formatDate(member.planEndDate!),
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
                        value: formatIndianShort(member.totalAmount!),
                      ),
                      AppTextSpan(
                        title: "Paid Amt",
                        value: formatIndianShort(member.amountPaid!),
                      ),
                      AppTextSpan(
                        title: "Due Amt",
                        value: formatIndianShort(member.amountDue!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0D000000), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              InoviceViewDownContainer(
                title: "Whatsapp",
                icon: FontAwesomeIcons.whatsapp,
                onTap: onWhatsApp,
              ),
              InoviceViewDownContainer(
                title: "Payment",
                icon: FontAwesomeIcons.moneyCheck,
                onTap: onPayment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
