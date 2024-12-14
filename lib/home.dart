import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? _cameraController;
  late TextRecognizer _textRecognizer;
  bool _isCameraInitialized = false;
  bool _isProcessingImage = false;
  String _recognizedText = "Initializing camera...";
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeTextRecognizer();
    _initializeCamera();
  }

  void _initializeTextRecognizer() {
    _textRecognizer = TextRecognizer();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        _cameraController!.startImageStream(_processCameraImage);

        setState(() {
          _isCameraInitialized = true;
        });
      } else {
        setState(() {
          _recognizedText = "No cameras found!";
        });
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      setState(() {
        _recognizedText = "Failed to initialize the camera.";
      });
    }
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (_isProcessingImage) return;

    _isProcessingImage = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      debugPrint("CameraImage bytes length: ${bytes.length}");

      final imageRotation = _getImageRotation();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(
            cameraImage.width.toDouble(),
            cameraImage.height.toDouble(),
          ),
          rotation: imageRotation,
          format: InputImageFormat.yv12,
          bytesPerRow: cameraImage.planes[0].bytesPerRow,
        ),
      );

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      debugPrint("Recognized Text: ${recognizedText.text}");

      if (mounted) {
        setState(() {
          _recognizedText = recognizedText.text.isNotEmpty
              ? recognizedText.text
              : "No text detected.";
        });
      }
    } catch (e) {
      debugPrint("Error processing image: $e");
      if (mounted) {
        setState(() {
          _recognizedText = "Error recognizing text.";
        });
      }
    } finally {
      _isProcessingImage = false;
    }
  }

  InputImageRotation _getImageRotation() {
    final orientation = WidgetsBinding.instance.platformDispatcher.views.first
                .physicalSize.aspectRatio >
            1
        ? InputImageRotation.rotation90deg
        : InputImageRotation.rotation0deg;

    return orientation;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Live Text Scanner",),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
