import 'package:flutter/material.dart';
import 'package:mobile_app/screens/signin.dart';
import 'package:mobile_app/services/auth_service.dart';

class AuthCheck extends StatelessWidget {
  final AuthService _authService = AuthService();
  AuthCheck({super.key});

  Future<bool> isAuthenticated() async {
    String? token = await _authService.getToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred. Please try again later.'),
          );
        }

        if (snapshot.hasData) {
          final bool isAuthenticated = snapshot.data!;
          if (isAuthenticated) {
            Future.microtask(() {
              Navigator.pushReplacementNamed(context, '/capture');
            });
          } else {
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            });
          }
        }
        
        return const SizedBox();
      },
    );
  }
}
