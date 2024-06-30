import 'dart:ui';
import 'package:bitblue_task/services/form/form_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/my_button.dart';
import '../components/text_field.dart';
import '../services/auth/auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.onTap}) : super(key: key);
  final void Function()? onTap;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.signInWithEmailAndPassword(
            _emailController.text, _passwordController.text);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _resetEmailController =
            TextEditingController();
        String errorMessage = '';

        return AlertDialog(
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _resetEmailController,
                decoration: const InputDecoration(hintText: "Enter your email"),
              ),
              const SizedBox(height: 10),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Send Reset Link"),
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  await authService.resetPassword(_resetEmailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Password reset link sent to ${_resetEmailController.text}"),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    if (e is Exception) {
                      errorMessage = e.toString();
                    } else {
                      errorMessage =
                          'Failed to send reset email. Please try again.';
                    }
                  });
                }
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

@override
void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SvgPicture.asset(
              'assets/images/login_background.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.account_circle, size: 120, color: Colors.blue)),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome to the App',
                          style: GoogleFonts.lobster(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            TextFieldComponent(
                              hintText: "example@gmail.com",
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              validator: FormValidators.validateEmail,
                            ),
                            const SizedBox(height: 20),
                            TextFieldComponent(
                              hintText: "Password",
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              validator: FormValidators.validatePassword,
                            ),
                            const SizedBox(height: 20),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ButtonComponent(
                                    onTap: login,
                                    text: "Login",
                                  ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Forgot your password?"),
                                TextButton(
                                  onPressed: forgotPassword,
                                  child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: widget.onTap,
                                  child: const Text("Register", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
