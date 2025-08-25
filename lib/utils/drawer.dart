import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lib_app/app/theme/app_snackbar.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/expense_provider.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/screens/auth/auth_screen.dart';
import 'package:lib_app/screens/expense/view_expense.dart';
import 'package:lib_app/screens/inovice/view_invoice.dart';
import 'package:lib_app/screens/library/libraries.dart';
import 'package:lib_app/screens/member/add_member.dart';
import 'package:lib_app/screens/member/view_members.dart';
import 'package:lib_app/screens/plan/add_plan.dart';
import 'package:lib_app/screens/plan/view_plans.dart';
import 'package:lib_app/screens/seat/view_seats.dart';
import 'package:lib_app/screens/user/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? currentLibraryName;
  String? currentLibraryId;

  @override
  void initState() {
    super.initState();
    _loadCurrentLibrary();
  }

  Future<void> _loadCurrentLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLibraryName = prefs.getString('currentLibraryName');
      currentLibraryId = prefs.getString('currentLibraryId');
    });
  }

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          _buildHeader(context),
          _drawerItem(
            Icons.person,
            "My Profile",
            onTap: () => _navigate(const UserProfile()),
          ),
          _expandableTile(
            icon: Icons.library_books,
            title: "Library",
            children: [
              _subItem(
                "Manage Seats",
                onTap: () => _navigate(ViewSeats(isNavigation: true)),
              ),
              _subItem(
                "Select Library",
                onTap: () => _navigate(Libraries(isNavigation: true)),
              ),
            ],
          ),
          _expandableTile(
            icon: Icons.people_alt,
            title: "Members",
            children: [
              _subItem(
                "Manage Members",
                onTap: () => _navigate(ViewMembers(isNavigation: true)),
              ),
              _subItem("Add Member", onTap: () => _navigate(const AddMember())),
            ],
          ),
          _expandableTile(
            icon: Icons.manage_accounts,
            title: "Plans",
            children: [
              _subItem(
                "Manage Plans",
                onTap: () => _navigate(const ViewPlans()),
              ),
              _subItem(
                "Add Plan",
                onTap: () {
                  if (currentLibraryId == null) {
                    AppSnackbar.showSnackbar(
                      context,
                      'No library selected. Please select a library first.',
                      AppColors.errorColor,
                    );
                    Navigator.pop(context);
                    return;
                  }
                  _navigate(const AddPlan());
                },
              ),
            ],
          ),
          _drawerItem(
            Icons.document_scanner,
            "Invoices",
            onTap: () => _navigate(const ViewInvoices()),
          ),
          _drawerItem(
            Icons.money_rounded,
            "Expenses",
            onTap: () => _navigate(Viewexpenses(isNavigation: true)),
          ),
          const Divider(),
          _drawerItem(Icons.logout, "Sign Out", onTap: _signOut),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? "User";
    return DrawerHeader(
      decoration: BoxDecoration(color: AppColors.primaryColor),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: const DecorationImage(
                  image: AssetImage('assets/images/editImage.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Hello, $userName',
              style: AppTextStyles.appbarTitleText(Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              'Welcome to LibroMen',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyText(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceColor,
        child: Icon(icon, color: AppColors.grey900Color),
      ),
      title: Text(title, style: AppTextStyles.bodyText(AppColors.grey900Color)),
      onTap: onTap,
    );
  }

  Widget _expandableTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceColor,
        child: Icon(icon, color: AppColors.grey900Color),
      ),
      title: Text(title, style: AppTextStyles.bodyText(AppColors.grey900Color)),
      childrenPadding: const EdgeInsets.only(left: 72, bottom: 8),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      children: children,
    );
  }

  Widget _subItem(String text, {required VoidCallback onTap}) {
    return ListTile(
      title: Text(text, style: AppTextStyles.bodyText(AppColors.grey900Color)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.only(left: 0),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentLibraryName');
      await prefs.remove('currentLibraryId');
      if (mounted) {
        final seatProvider = Provider.of<SeatProvider>(context, listen: false);
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );
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
        expenseProvider.clear();
        invoiceProvider.clear();
        libraryProvider.clear();
        memberProvider.clear();
        planProvider.clear();
        seatProvider.clear();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      Fluttertoast.showToast(
        msg: "Sign Out Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      // Optionally handle error
      Fluttertoast.showToast(
        msg: "Failed to sign out : $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primaryColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
