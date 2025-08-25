import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/screens/member/renew_member.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:lib_app/widgets/inovice_view_down_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUpMembers extends StatefulWidget {
  const FollowUpMembers({super.key});

  @override
  State<FollowUpMembers> createState() => _FollowUpMembersState();
}

class _FollowUpMembersState extends State<FollowUpMembers> {
  String? currenLibraryId;
  List<MemberModel> membersWithPlanEndingSoon = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    currenLibraryId = prefs.getString('currentLibraryId');
    if (!mounted) return;
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    setState(() {
      membersWithPlanEndingSoon = memberProvider.membersWithPlanEndingSoon;
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
      appBar: AppAppBar(title: 'Follow Up Members'),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadData();
                  },
                  child: ListView.builder(
                    itemCount: membersWithPlanEndingSoon.length,
                    itemBuilder: (context, index) {
                      final member = membersWithPlanEndingSoon[index];
                      return _MemberCard(
                        member: member,
                        onWhatsApp: () {
                          final phone =
                              "91${member.phone!.replaceAll(" ", "")}";
                          final endDate = formatDate(member.planEndDate!);
                          final message =
                              "Hello ${member.name}, your membership will expire or has expired on $endDate. If you want to renew, please reply or call us.";
                          _sendWhatsAppMessage(phone, message);
                        },
                        onRenew: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => RenewMember(memberData: member),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onWhatsApp;
  final VoidCallback onRenew;

  const _MemberCard({
    required this.member,
    required this.onWhatsApp,
    required this.onRenew,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final joinDate = formatDate(member.dateOfJoining!);
    final startDate = formatDate(member.planStartDate!);
    final endDate = formatDate(member.planEndDate!);

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
          const Divider(color: Color(0x0D000000), thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextSpan(title: "Join Date", value: joinDate),
                AppTextSpan(title: "Phone", value: member.phone!),
                if (member.email != null)
                  AppTextSpan(title: "Email", value: member.email!),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0x0D000000), thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextSpan(
                        title: "Plan",
                        value: member.currentPlan!.name!,
                      ),
                      AppTextSpan(title: "Start Date", value: startDate),
                      AppTextSpan(title: "End Date", value: endDate),
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
          const Divider(color: Color(0x0D000000), thickness: 1),
          Row(
            children: [
              InoviceViewDownContainer(
                title: "Whatsapp",
                icon: FontAwesomeIcons.whatsapp,
                onTap: onWhatsApp,
              ),
              InoviceViewDownContainer(
                title: "Renew",
                icon: FontAwesomeIcons.refresh,
                onTap: onRenew,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
