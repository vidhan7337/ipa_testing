import 'package:flutter/material.dart';
import 'package:lib_app/Functions/convert.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/due_reminder_members.dart';
import 'package:lib_app/screens/expense/view_expense.dart';
import 'package:lib_app/screens/follow_up_members.dart';
import 'package:lib_app/screens/inovice/view_invoice.dart';
import 'package:lib_app/screens/member/view_members.dart';
import 'package:lib_app/screens/seat/view_seats.dart';
import 'package:lib_app/widgets/home_list_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/providers/expense_provider.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? currentLibraryId;
  String? currentLibraryName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    currentLibraryId = prefs.getString('currentLibraryId');
    currentLibraryName = prefs.getString('currentLibraryName');
    if (currentLibraryId == null) {
      if (!mounted) return;
      AppSnackbar.showSnackbar(
        context,
        'No library selected. Please select or add a library first.',
        AppColors.errorColor,
      );
      setState(() => isLoading = false);
      return;
    }
    if (!mounted) return;
    final seatProvider = Provider.of<SeatProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    await Future.wait([
      seatProvider.loadseats(currentLibraryId!),
      memberProvider.loadmembers(currentLibraryId!),
      expenseProvider.loadexpenses(currentLibraryId!),
      libraryProvider.loadlibraries(FirebaseAuth.instance.currentUser!.uid),
      invoiceProvider.loadinvoices(currentLibraryId!),
      planProvider.loadPlans(currentLibraryId!),
    ]);

    // for (var seat in seatProvider.seats) {
    //   if (seat.expirationDate != null &&
    //       (seat.expirationDate!.difference(DateTime.now()).inDays <= 1)) {
    //     if (seat.isBooked == true && seat.isNoticed == false) {
    //       seat.isNoticed = true;
    //       await seatProvider.updateseat(currentLibraryId!, seat);
    //     }
    //   }
    // }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : RefreshIndicator(
                onRefresh: _initializeData,
                child: SafeArea(
                  child: ListView(
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 30,
                        ),
                        child: Column(
                          children: [
                            _sectionHeader(
                              icon: Icons.people,
                              title: "Manage Library Seats",
                              onViewAll: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ViewSeats(isNavigation: true),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _seatsSummary(seatProvider),
                            const SizedBox(height: 20),
                            HomeListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ViewMembers(
                                          isNavigation: true,
                                        ),
                                  ),
                                );
                              },
                              backgroundColor: AppColors.backgroundColor,
                              surfaceColor: AppColors.surfaceColor,
                              mainColor: AppColors.primaryColor,
                              title: "Total Members",
                              icon: Icons.people,
                              value: "${memberProvider.members.length}",
                            ),
                            const SizedBox(height: 10),
                            HomeListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ViewMembers(
                                          isNavigation: true,
                                        ),
                                  ),
                                );
                              },
                              backgroundColor: AppColors.backgroundColor,
                              surfaceColor: AppColors.surfaceColor,
                              mainColor: AppColors.primaryColor,
                              title: "Active Members",
                              icon: Icons.people,
                              value: "${memberProvider.activeMembersCount}",
                            ),
                            const SizedBox(height: 10),
                            HomeListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ViewMembers(
                                          isNavigation: true,
                                        ),
                                  ),
                                );
                              },
                              backgroundColor: AppColors.backgroundColor,
                              surfaceColor: AppColors.surfaceColor,
                              mainColor: AppColors.primaryColor,
                              title: "Expired Members",
                              icon: Icons.people,
                              value: "${memberProvider.inactiveMembersCount}",
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20, color: AppColors.backgroundColor),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 30,
                        ),
                        child: Column(
                          children: [
                            _sectionHeader(
                              icon: Icons.wallet,
                              title: "Manage Payments",
                              onViewAll: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewInvoices(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _paymentsSummary(memberProvider),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DueReminderMembers(),
                                  ),
                                );
                              },
                              child: HomeListTile(
                                backgroundColor:
                                    AppColors.backgroundSecondaryColor,
                                surfaceColor: AppColors.surfaceSecondaryColor,
                                mainColor: AppColors.secondaryColor,
                                title: "Due Reminders",
                                icon: Icons.wallet,
                                value:
                                    memberProvider.membersWithDueAmount
                                        .toString(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowUpMembers(),
                                  ),
                                );
                              },
                              child: HomeListTile(
                                backgroundColor:
                                    AppColors.backgroundSecondaryColor,
                                surfaceColor: AppColors.surfaceSecondaryColor,
                                mainColor: AppColors.secondaryColor,
                                title: "Renew Reminders",
                                icon: Icons.event,
                                value:
                                    memberProvider
                                        .membersWithPlanEndingSoonCount
                                        .toString(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            HomeListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const Viewexpenses(
                                          isNavigation: true,
                                        ),
                                  ),
                                );
                              },
                              backgroundColor:
                                  AppColors.backgroundSecondaryColor,
                              surfaceColor: AppColors.surfaceSecondaryColor,
                              mainColor: AppColors.secondaryColor,
                              title: "Expenses",
                              icon: Icons.chair,
                              value: formatIndianShort(
                                expenseProvider.totalExpense,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.grey800Color, size: 15),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.bodyTitleText(AppColors.grey800Color),
            ),
          ],
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            "View All",
            style: AppTextStyles.bodySmallSemiBoldText(AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _seatsSummary(SeatProvider seatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryColumn(
            label: "Total Seats",
            icon: Icons.chair,
            value: seatProvider.seats.length.toString(),
          ),
          Container(
            height: 50,
            width: 1,
            color: const Color(0xffe8e8e8).withOpacity(0.2),
          ),
          _summaryColumn(
            label: "Available Seats",
            icon: Icons.chair,
            value: seatProvider.totalAvailableSeats.toString(),
          ),
        ],
      ),
    );
  }

  Widget _paymentsSummary(MemberProvider memberProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryColumn(
            label: "Total Collection",
            icon: Icons.money,
            value: formatIndianShort(memberProvider.totalpayment),
          ),
          Container(
            height: 50,
            width: 1,
            color: const Color(0xffe8e8e8).withOpacity(0.2),
          ),
          _summaryColumn(
            label: "Due Amount",
            icon: Icons.money,
            value: formatIndianShort(memberProvider.totalDueAmt),
          ),
        ],
      ),
    );
  }

  Widget _summaryColumn({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.subBodyText(Colors.white)),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 15),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
