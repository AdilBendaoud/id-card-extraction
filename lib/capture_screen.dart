import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:mobile_app/result_screen.dart';

class CaptureScreen extends StatefulWidget {
  final CameraDescription camera;

  const CaptureScreen({super.key, required this.camera});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Initialize camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcessImage(BuildContext context) async {
    try {
      await _initializeControllerFuture;

      // Capture image
      final image = await _controller.takePicture();
      print('Captured image path: ${image.path}');

      // Crop image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
        compressQuality: 90,
      );

      if (croppedFile != null) {
        print('Cropped image path: ${croppedFile.path}');

        // Verify cropped file existence
        if (!await File(croppedFile.path).exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cropped image file not found!')),
          );
          return;
        }

        final response = await _sendToBackend(croppedFile.path);
        print('Backend response: $response');

        // Display result
        if (response != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(data: response),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error processing the image!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image cropping cancelled')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing the image!')),
      );
    }
  }

  Future<Map<String, dynamic>?> _sendToBackend(String imagePath) async {
    final url = Uri.parse('http://192.168.1.7:5000/process-image');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    print('Status: ${response.statusCode}, Body: $responseBody');

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture ID Card'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _captureAndProcessImage(context),
        child: const Icon(Icons.camera),
      ),
    );
  }
}
