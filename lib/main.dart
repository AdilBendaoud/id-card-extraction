import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_app/auth_check.dart';
import 'package:mobile_app/screens/signin.dart';
import 'package:mobile_app/screens/signup.dart';
import 'package:mobile_app/screens/verify_email.dart';
import 'capture_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth-check',
      routes: {
        '/auth-check': (context) => AuthCheck(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/capture': (context) => CaptureScreen(camera: camera),
        '/verify-email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
