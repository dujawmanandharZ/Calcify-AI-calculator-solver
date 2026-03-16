import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // --- State Management ---
  CameraController? controller;    // Interface for the device camera
  List<CameraDescription>? cameras; // List of available hardware (front/back)
  File? image;                     // The current image being displayed or analyzed
  final picker = ImagePicker();    // Helper for gallery selection

  bool isProcessing = false;       // Used to trigger the loading spinner
  String solvedText = "";          // Holds the final AI-generated response

  @override
  void initState() {
    super.initState();
    _initializeCamera();           // Auto-start camera on page entry
  }

  // Initializing the camera hardware
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    
    // Using ResolutionPreset.medium to balance image quality with network speed
    controller = CameraController(
      cameras![0], 
      ResolutionPreset.medium,
      enableAudio: false, // Disabling audio to reduce unnecessary permissions
    );

    await controller!.initialize();

    if (mounted) {
      setState(() {}); // Update UI once controller is ready
    }
  }

  // Method to select an image from the device gallery
  Future<void> pickFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
        solvedText = ""; // Clear old results when new image is selected
      });
    }
  }

  // Method to snap a picture from the live feed
  Future<void> captureImage() async {
    if (controller != null && controller!.value.isInitialized) {
      final file = await controller!.takePicture();

      setState(() {
        image = File(file.path);
        solvedText = "";
      });
    }
  }

  // ============================================================
  // AI INTEGRATION: Communicating with Gemini 2.5 Flash
  // ============================================================
  Future<void> solveWithAI() async {
    if (image == null) return;

    setState(() {
      isProcessing = true;
      solvedText = "Analyzing problem...";
    });

    try {
      // 1. Convert image to Base64 for the JSON request
      final bytes = await image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // ⚠️ Note: In production, use flutter_dotenv to secure your API Key
      const String apiKey = "*********************************";
      final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
      );

      // 2. Construct the multimodal request (Text Prompt + Image Data)
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "You are an expert math tutor. Identify the math problem in this image and solve it step-by-step with clear Markdown."
                },
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Image,
                  },
                },
              ],
            },
          ],
        }),
      );

      // 3. Handle the server response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["candidates"] != null && data["candidates"].isNotEmpty) {
          String aiResponse = data["candidates"][0]["content"]["parts"][0]["text"];
          setState(() => solvedText = aiResponse);
        } else {
          setState(() => solvedText = "AI could not detect a math problem.");
        }
      } else {
        setState(() => solvedText = "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => solvedText = "Connection failed. Try again.");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  void dispose() {
    // Memory Management: Clean up the camera resources
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CALCIFY",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, size: 40),
            onPressed: () {
              setState(() {
                image = null;
                solvedText = "";
              });
              _initializeCamera();
            },
          ),
        ],
      ),
      body: Column(
        
        children: [
          // --- Main Viewfinder / Result Screen ---
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildMainContent(),
                  ),
                ),
              ),
            ),
          ),

          // --- Bottom Control Bar ---
          _buildButtonRow(),
        ],
      ),
    );
  }

  // Logic to determine what to show in the main display
  Widget _buildMainContent() {
    if (isProcessing) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }
    
    if (solvedText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            solvedText,
            style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
          ),
        ),
      );
    }

    if (image != null) {
      return Image.file(image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }

    // Full-screen Viewfinder Logic
    if (controller != null && controller!.value.isInitialized) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * controller!.value.aspectRatio,
                child: CameraPreview(controller!),
              ),
            ),
          );
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  // Customized Buttons (Orange with Black Text)
  Widget _buildButtonRow() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Gallery Button
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                onPressed: pickFromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Solve Button
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Solve"),
                onPressed: () async {
                  if (image == null) await captureImage();
                  await solveWithAI();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
