import 'package:flutter/material.dart';

import '../../Pages/Login.dart';
import '../../Pages/Registration_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginScreen = true;
  void toggleScreen() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return Login(
        onTap: () {
          toggleScreen();
        },
      );
    } else {
      return RegistrationPage(
        onTap: () {
          toggleScreen();
        },
      );
    }
  }
}
