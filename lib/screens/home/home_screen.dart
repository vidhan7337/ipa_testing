import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/expense/view_expense.dart';
import 'package:lib_app/screens/home/home.dart';
import 'package:lib_app/screens/library/libraries.dart';
import 'package:lib_app/screens/member/view_members.dart';
import 'package:lib_app/screens/seat/view_seats.dart';
import 'package:lib_app/screens/user/profile.dart';
import 'package:lib_app/utils/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? currentLibraryName;

  static final List<Widget> _pages = [
    Home(),
    Libraries(),
    ViewSeats(),
    ViewMembers(),
    Viewexpenses(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLibraryName ?? 'LibroMen',
          style: AppTextStyles.appbarTitleText(AppColors.grey800Color),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: AppColors.grey800Color),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfile()),
              );
            },
            icon: Icon(Icons.person_rounded, color: AppColors.grey800Color),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: Container(
        height: 100,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, -2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: AppTextStyles.bodySmallSemiBoldText(
            AppColors.primaryColor,
          ),
          unselectedLabelStyle: AppTextStyles.bodySmallText(
            AppColors.grey600Color,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chair_alt),
              label: 'Seats',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Members'),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Expenses',
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
