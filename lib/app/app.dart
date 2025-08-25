import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/providers/expense_provider.dart';
import 'package:lib_app/providers/invoice_provider.dart';
import 'package:lib_app/providers/library_provider.dart';
import 'package:lib_app/providers/member_provider.dart';
import 'package:lib_app/providers/plan_provider.dart';
import 'package:lib_app/providers/seat_provider.dart';
import 'package:lib_app/providers/tax_provider.dart';
import 'package:lib_app/providers/user_provider.dart';
import 'package:lib_app/screens/auth/auth_screen.dart';
import 'package:lib_app/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlanProvider()),
        ChangeNotifierProvider(create: (context) => SeatProvider()),
        ChangeNotifierProvider(create: (context) => TaxProvider()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (context) => InvoiceProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Library App',
        theme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.backgroundBlueColor,
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home:
            FirebaseAuth.instance.currentUser == null ||
                    !FirebaseAuth.instance.currentUser!.emailVerified
                ? const AuthScreen()
                : const HomeScreen(),
      ),
    );
  }
}
