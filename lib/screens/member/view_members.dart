import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/models/member_model.dart';
import 'package:lib_app/models/seat_model.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/screens/member/add_member.dart';
import 'package:lib_app/screens/member/add_payment.dart';
import 'package:lib_app/screens/member/edit_member.dart';
import 'package:lib_app/screens/member/member_profile.dart';
import 'package:lib_app/screens/member/renew_member.dart';
import 'package:lib_app/utils/Drop_down_text_field.dart';
import 'package:lib_app/utils/appbar.dart';
import 'package:lib_app/utils/text_field_label.dart';
import 'package:lib_app/utils/textspan.dart';
import 'package:lib_app/widgets/member_profile_down_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewMembers extends StatefulWidget {
  final bool? isNavigation;
  const ViewMembers({super.key, this.isNavigation});

  @override
  State<ViewMembers> createState() => _ViewMembersState();
}

class _ViewMembersState extends State<ViewMembers> {
  String? currentLibraryId;
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<MemberModel>> filteredMembers = ValueNotifier([]);
  String dropdownValue = 'asc';
  String tabValue = 'total';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    if (currentLibraryId == null) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select a library first.',
        AppColors.errorColor,
      );
      setState(() => isLoading = false);
      return;
    }
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    await memberProvider.loadmembers(currentLibraryId!);
    _applyFilters();
    setState(() => isLoading = false);
  }

  void _applyFilters() {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    List<MemberModel> members = List.from(memberProvider.members);

    // Tab filter
    if (tabValue == 'active') {
      members = members.where((m) => m.isActive == true).toList();
    } else if (tabValue == 'expired') {
      members = members.where((m) => m.isActive == false).toList();
    }

    // Search filter
    final search = searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      members =
          members.where((member) {
            return (member.name ?? '').toLowerCase().contains(search) ||
                (member.id ?? '').toLowerCase().contains(search) ||
                (member.seatId ?? '').toLowerCase().contains(search) ||
                (member.phone ?? '').toLowerCase().contains(search);
          }).toList();
    }

    // Sort
    if (dropdownValue == 'asc') {
      members.sort((a, b) => a.name!.compareTo(b.name!));
    } else if (dropdownValue == 'desc') {
      members.sort((a, b) => b.name!.compareTo(a.name!));
    } else if (dropdownValue == 'join') {
      members.sort((a, b) => a.dateOfJoining!.compareTo(b.dateOfJoining!));
    } else if (dropdownValue == 'due') {
      members.sort((a, b) => b.amountDue!.compareTo(a.amountDue!));
    }

    filteredMembers.value = members;
  }

  Future<void> deleteMember(MemberModel member) async {
    setState(() => isLoading = true);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);

    if (member.seatId != "Rotational Seat") {
      String emptySeatId = member.seatId!;
      String? emptySeries;
      int? emptySeatNumber;
      if (emptySeatId.contains('_')) {
        var parts = emptySeatId.split('_');
        if (parts.length == 2) {
          emptySeries = parts[0];
          emptySeatNumber = int.tryParse(parts[1]);
        }
      }
      final emptySeat = SeatModel(
        seatId: member.seatId!,
        seatNumber: emptySeatNumber,
        series: emptySeries,
        isBooked: false,
        memberId: null,
        expirationDate: null,
        isNoticed: false,
      );
      await seatProvider.updateseat(currentLibraryId!, emptySeat);
    }
    member.isActive = false;
    member.seatId = null;
    await memberProvider.updatemember(member, currentLibraryId!);
    setState(() => isLoading = false);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);
    return Scaffold(
      appBar:
          (widget.isNavigation ?? false)
              ? AppAppBar(title: 'View Members')
              : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          if (currentLibraryId == null) {
            AppSnackbar.showSnackbar(
              context,
              'No library selected. Please select a library first.',
              AppColors.errorColor,
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMember()),
          ).then((_) => _initData());
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : memberProvider.members.isEmpty
              ? Center(
                child: Text(
                  'No Members Available',
                  style: AppTextStyles.bodyTitleText(AppColors.primaryColor),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomLLabelTextField(
                      icon: Icons.search,
                      controller: searchController,
                      onChanged: (value) => _applyFilters(),
                      hintText: 'Search Members',
                      suffixIcon: Icons.filter_list,
                      onSuffixIconPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                      'Sort Members',
                                      style: AppTextStyles.appbarTitleText(
                                        AppColors.grey900Color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  DropDownTextField(
                                    hintText: "Sort By",
                                    Item: const [
                                      DropdownMenuItem(
                                        value: 'asc',
                                        child: Text('Name Ascending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'desc',
                                        child: Text('Name Descending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'join',
                                        child: Text('Join Date'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'due',
                                        child: Text('Due Amount'),
                                      ),
                                    ],
                                    value: dropdownValue,
                                    onChanged: (value) {
                                      dropdownValue = value!;
                                      Navigator.pop(context);
                                      _applyFilters();
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _TabBar(
                      tabValue: tabValue,
                      memberProvider: memberProvider,
                      onTabChanged: (val) {
                        setState(() {
                          tabValue = val;
                        });
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ValueListenableBuilder<List<MemberModel>>(
                        valueListenable: filteredMembers,
                        builder: (context, members, _) {
                          if (isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            );
                          }
                          if (members.isEmpty) {
                            return Center(
                              child: Text(
                                'No Members Found',
                                style: AppTextStyles.bodyTitleText(
                                  AppColors.primaryColor,
                                ),
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: _initData,
                            child: ListView.builder(
                              itemCount: members.length,
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return _MemberListItem(
                                  member: member,
                                  onDelete: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        bool isDeleting = false;
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  AppColors.backgroundBlueColor,
                                              title: Text(
                                                'Delete member',
                                                style:
                                                    AppTextStyles.appbarTitleText(
                                                      AppColors.primaryColor,
                                                    ),
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(
                                                      'This Member will be expired (Please complete the dues before deleting)',
                                                      style:
                                                          AppTextStyles.bodyText(
                                                            Colors.black,
                                                          ),
                                                    ),
                                                    Text(
                                                      'Would you like to delete this member?',
                                                      style:
                                                          AppTextStyles.bodyText(
                                                            Colors.black,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                isDeleting
                                                    ? Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16.0,
                                                          ),
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                AppColors
                                                                    .errorColor,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    : TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                            backgroundColor:
                                                                AppColors
                                                                    .errorColor,
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                      onPressed: () async {
                                                        setState(
                                                          () =>
                                                              isDeleting = true,
                                                        );
                                                        await deleteMember(
                                                          member,
                                                        );
                                                        AppSnackbar.showSnackbar(
                                                          context,
                                                          'Member deleted successfully',
                                                          AppColors.errorColor,
                                                        );
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true);
                                                      },
                                                    ),
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                    if (result == true) _applyFilters();
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final String tabValue;
  final MemberProvider memberProvider;
  final ValueChanged<String> onTabChanged;

  const _TabBar({
    required this.tabValue,
    required this.memberProvider,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: "Total: ${memberProvider.members.length}",
          selected: tabValue == 'total',
          onTap: () => onTabChanged('total'),
        ),
        const SizedBox(width: 5),
        _TabButton(
          label: "Active: ${memberProvider.activeMembersCount}",
          selected: tabValue == 'active',
          onTap: () => onTabChanged('active'),
        ),
        const SizedBox(width: 5),
        _TabButton(
          label: "Expired: ${memberProvider.inactiveMembersCount}",
          selected: tabValue == 'expired',
          onTap: () => onTabChanged('expired'),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primaryColor : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x0d000000), width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodySmallSemiBoldText(
                selected ? Colors.white : AppColors.grey800Color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberListItem extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onDelete;

  const _MemberListItem({required this.member, required this.onDelete});

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
          // ... (rest of your member item UI, unchanged)
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
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0x0D000000),
          ),
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
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0x0D000000),
          ),
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
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0x0D000000),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              MemberProfileDownContainer(
                title: "Profile",
                icon: Icons.remove_red_eye,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberProfile(memberModel: member),
                    ),
                  );
                },
              ),
              MemberProfileDownContainer(
                title: "Edit",
                icon: Icons.edit,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMember(member: member),
                    ),
                  );
                },
              ),
              MemberProfileDownContainer(
                title: "Renew",
                icon: Icons.refresh,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RenewMember(memberData: member),
                    ),
                  );
                },
              ),
              MemberProfileDownContainer(
                title: "Payment",
                icon: Icons.money,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPayment(memberModel: member),
                    ),
                  );
                },
              ),
              MemberProfileDownContainer(
                title: "Delete",
                icon: Icons.delete,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
