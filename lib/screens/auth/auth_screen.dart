import 'package:flutter/material.dart';
import 'package:lib_app/app/theme/app_text_styles.dart';
import 'package:lib_app/app/theme/colors.dart';
import 'package:lib_app/screens/auth/login.dart';
import 'package:lib_app/screens/auth/register.dart';
import 'package:lib_app/utils/logo_container.dart';
import 'package:lib_app/utils/tab_container.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginSelected = true;

  void _onTabSelected(bool isLogin) {
    if (_isLoginSelected != isLogin) {
      setState(() {
        _isLoginSelected = isLogin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.35;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size.height * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: logoSize,
                    height: logoSize,

                    child: Image.asset('assets/images/Group.png'),
                  ),
                  // LogoContainer(
                  //   size: logoSize,
                  //   boxColor: AppColors.primaryColor,
                  //   logoColor: Colors.white,
                  // ),
                  Text(
                    "Libraria",
                    style: AppTextStyles.mainHeading(AppColors.grey900Color),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Find your perfect study spot",
                    style: AppTextStyles.subHeading(AppColors.grey600Color),
                  ),
                  SizedBox(height: size.height * 0.08),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: size.width * 0.86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: const Color(0x0D000000),
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTabSelected(true),
                                child: TabContainer(
                                  title: "Login",
                                  isSelected: _isLoginSelected,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onTabSelected(false),
                                child: TabContainer(
                                  title: "Register",
                                  isSelected: !_isLoginSelected,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder:
                              (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                          child:
                              _isLoginSelected
                                  ? const Login()
                                  : const Register(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
