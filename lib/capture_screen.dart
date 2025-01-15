import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:mobile_app/config.dart';
import 'package:mobile_app/result_screen.dart';
import 'package:mobile_app/services/auth_service.dart';

class CaptureScreen extends StatefulWidget {
  final CameraDescription camera;

  const CaptureScreen({super.key, required this.camera});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final AuthService _authService = AuthService();
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraOpen = false;
  String? _capturedImagePath;
  bool _isLoading = false;

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      _isCameraOpen = true;
      _capturedImagePath = null;
    });
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;

      // Capture image
      final image = await _controller.takePicture();
      setState(() {
        _capturedImagePath = image.path;
      });
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error capturing the image!')),
      );
    }
  }

  Future<void> _sendImageToBackend(BuildContext context) async {
    if (_capturedImagePath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _sendToBackend(_capturedImagePath!);
      print('Backend response: $response');

      // Display result
      if (response != null) {
        setState(() {
          _isCameraOpen = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(data: response['data']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error processing the image!')),
        );
      }
    } catch (e) {
      print('Error sending image to backend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending the image to the backend!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _sendToBackend(String imagePath) async {
    final token = await _authService.getToken();
    final url = Uri.parse('${Appconfig.baseUrl}/api/id-scan/process-image');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Capture ID Card'),
            IconButton(
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/signin');
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing Image...',style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : _isCameraOpen
              ? _capturedImagePath == null
                  ? FutureBuilder<void>(
                      future: _initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Stack(
                            children: [
                              CameraPreview(_controller),
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: FloatingActionButton(
                                    onPressed: () async {
                                      await _captureImage();
                                    },
                                    child: const Icon(Icons.camera),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.file(File(_capturedImagePath!)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _initializeCamera();
                              },
                              child: const Text('Retake'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await _sendImageToBackend(context);
                              },
                              child: const Text('Validate'),
                            ),
                          ],
                        ),
                      ],
                    )
              : Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _initializeCamera,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 10),
                          Text('Open Camera')
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
