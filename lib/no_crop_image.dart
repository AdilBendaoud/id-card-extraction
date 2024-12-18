import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> captureAndUploadImage() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      // Capture the image
      final image = await _cameraController.takePicture();
      print('Captured image path: ${image.path}');

      // Upload the image to the backend
      await sendToBackend(image.path);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> sendToBackend(String imagePath) async {
    try {
      final uri = Uri.parse('http://192.168.1.7:5000/process-image');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> extractedData = jsonDecode(responseData);

        // Navigate to ResultScreen with the extracted data
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(data: extractedData),
            ),
          );
        }
      } else {
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_cameraController.value.isInitialized)
            CameraPreview(_cameraController)
          else
            const Center(child: CircularProgressIndicator()),
          if (isProcessing)
            Center(
              child: Container(
                color: Colors.black54,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: captureAndUploadImage,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
