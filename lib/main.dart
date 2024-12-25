import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
      initialRoute: '/signin',
      routes: {
        '/signin': (context) => SignInScreen(camera: camera),
        '/signup': (context) => SignUpScreen(),
        '/capture': (context) => CaptureScreen(camera: camera),
        '/verify-email': (context) => VerifyEmailScreen(),
      },
    );
  }
}
