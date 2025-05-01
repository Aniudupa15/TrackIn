import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File

class TakeAttendence extends StatefulWidget {
  const TakeAttendence({Key? key}) : super(key: key);

  @override
  State<TakeAttendence> createState() => _TakeAttendenceState();
}

class _TakeAttendenceState extends State<TakeAttendence> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  // Function to take a photo
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  // Function to handle submission (e.g., uploading the image)
  void _submitPhoto() {
    if (_image != null) {
      // Here you can add the code for the submission (e.g., upload to server or save locally)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo Submitted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo first!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            // Display the taken photo if available
            _image != null
                ? Column(
              children: [
                Image.file(File(_image!.path), height: 200),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPhoto, // Submit the photo
                  child: const Text('Submit Photo'),
                ),
              ],
            )
                : const Text('No photo taken yet'),
          ],
        ),
      ),
    );
  }
}
