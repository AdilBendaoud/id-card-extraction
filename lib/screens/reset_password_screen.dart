import 'package:flutter/material.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:animate_do/animate_do.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final AuthService authService = AuthService();

  void resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    final token = tokenController.text;

    if (token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword) {
      showErrorDialog("Passwords do not match.");
      return;
    }

    final success = await authService.resetPassword(token, newPassword, confirmPassword);

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Password reset successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signin');
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showErrorDialog("Failed to reset password. Please try again.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader("Reset Password"),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: buildTextField("Code", tokenController, false),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: buildTextField("New Password", newPasswordController, true),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: buildTextField("Confirm Password", confirmPasswordController, true),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1900),
                    child: GestureDetector(
                      onTap: resetPassword,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller, bool obscureText) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: const Color.fromRGBO(143, 148, 251, 1))),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 30,
            width: 80,
            height: 200,
            child: FadeInUp(
              duration: const Duration(seconds: 1),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/light-1.png'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 140,
            width: 80,
            height: 150,
            child: FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/light-2.png'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 40,
            width: 80,
            height: 150,
            child: FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/clock.png'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: FadeInUp(
              duration: const Duration(milliseconds: 1600),
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}