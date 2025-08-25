import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/auth/auth_screen.dart';
import 'package:lib_app/screens/auth/email_verify.dart';
import 'package:lib_app/screens/home/home_screen.dart';
import 'package:lib_app/utils/logo_container.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<Widget> getInitialScreen() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulate loading or animation

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload(); // refresh email verification status
      user = FirebaseAuth.instance.currentUser;

      if (user!.emailVerified) {
        return const HomeScreen();
      } else {
        return EmailVerify(email: user.email!);
      }
    } else {
      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.35;
    return FutureBuilder(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 1), // Adjust the height as needed
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoContainer(
                          size: logoSize,
                          boxColor: Colors.white,
                          logoColor: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "LibroMen",
                          style: AppTextStyles.mainHeading(Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Find your perfect study spot",
                          style: AppTextStyles.subHeading(Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 50,
                      right: 50,
                      bottom: screenWidth * 0.35,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ), // Set border color and width
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(16),
                        backgroundColor: AppColors.primaryColor,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return snapshot.data as Widget;
        } else {
          return const Center(child: Text('Error loading screen'));
        }
      },
    );
  }
}
