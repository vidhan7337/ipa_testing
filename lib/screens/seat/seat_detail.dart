import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/models/seat_model.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/screens/member/member_profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeatDetail extends StatefulWidget {
  final SeatModel? seat;
  final String? memberId;
  const SeatDetail({super.key, this.seat, this.memberId});

  @override
  State<SeatDetail> createState() => _SeatDetailState();
}

class _SeatDetailState extends State<SeatDetail> {
  MemberModel? member;
  String? currentLibraryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (!mounted || currentLibraryId == null) return;
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.loadmembers(currentLibraryId!);
    member = memberProvider.getMemberById(widget.memberId ?? '');
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: AppTextStyles.bodyText(labelColor ?? AppColors.grey700Color),
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.bodyText(valueColor ?? AppColors.grey900Color),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: Color(0x0D000000)),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
                : member == null
                ? const Center(child: Text('Member not found'))
                : SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/chair_icon.svg',
                                  color: Colors.white,
                                  height: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Seat No - ${widget.seat?.fullSeatNumber ?? ''}",
                                  style: AppTextStyles.bodyText(Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildInfoRow('Name', member!.name ?? ''),
                      _buildDivider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MemberProfile(memberModel: member!),
                            ),
                          );
                        },
                        child: _buildInfoRow(
                          'Member ID',
                          member!.id ?? '',
                          labelColor: AppColors.primaryColor,
                          valueColor: AppColors.primaryColor,
                        ),
                      ),
                      _buildDivider(),
                      _buildInfoRow('Plan', member!.currentPlan?.name ?? ''),
                      _buildDivider(),
                      _buildInfoRow(
                        'End Date',
                        member!.planEndDate != null
                            ? formatDate(member!.planEndDate!)
                            : '',
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
      ),
    );
  }
}
