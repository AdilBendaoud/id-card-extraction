import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile_app/capture_screen.dart';
import 'package:mobile_app/no_crop_image.dart';

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
      home: CaptureScreen(camera: camera),
    );
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: CameraScreen()
    // );
  }
}