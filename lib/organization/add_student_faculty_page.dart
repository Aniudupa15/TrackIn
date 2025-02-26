import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AddStudentFacultyPage extends StatefulWidget {
  const AddStudentFacultyPage({super.key});

  @override
  _AddStudentFacultyPageState createState() => _AddStudentFacultyPageState();
}

class _AddStudentFacultyPageState extends State<AddStudentFacultyPage> {
  List<File> _imageFiles = [];
  String? _selectedFolderPath;
  final TextEditingController _folderNameController = TextEditingController();

  // Request storage permission
  Future<bool> _requestPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.manageExternalStorage.request(); // Android 11+
    } else if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else {
      status = PermissionStatus.granted;
    }

    if (status.isGranted) {
      return true;
    } else {
      _showPermissionDeniedMessage();
      return false;
    }
  }

  // Function to show permission denied message
  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(
        content: Text("Storage permission is required to select a folder!"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Function to let user select a folder
  Future<void> _pickFolder() async {
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        setState(() {
          _selectedFolderPath = selectedDirectory;
          _imageFiles = _getImageFilesFromFolder(selectedDirectory);
          _folderNameController.text = basename(selectedDirectory); // Set default folder name
        });

        if (kDebugMode) {
          print("Folder Selected: $_selectedFolderPath");
        }
        if (kDebugMode) {
          print("Total Images Found: ${_imageFiles.length}");
        }
      } else {
        if (kDebugMode) {
          print("No folder selected");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking folder: $e");
      }
    }
  }

  // Function to get all image files from the selected folder
  List<File> _getImageFilesFromFolder(String folderPath) {
    Directory dir = Directory(folderPath);
    List<File> imageFiles = [];

    if (dir.existsSync()) {
      imageFiles = dir
          .listSync()
          .where((file) =>
      file is File &&
          (file.path.endsWith(".jpg") ||
              file.path.endsWith(".jpeg") ||
              file.path.endsWith(".png")))
          .map((file) => File(file.path))
          .toList();
    }

    return imageFiles;
  }

  // Function to upload images to an API
  Future<void> _uploadFolder() async {
    if (_selectedFolderPath == null || _imageFiles.isEmpty) {
      _showMessage("Please select a folder first!");
      return;
    }

    String newFolderName = _folderNameController.text.trim();
    if (newFolderName.isEmpty) {
      _showMessage("Folder name cannot be empty!");
      return;
    }

    var request = http.MultipartRequest(
        "POST", Uri.parse("https://your-api.com/upload"));

    // Add folder name to request
    request.fields["folder_name"] = newFolderName;

    // Attach image files
    for (var file in _imageFiles) {
      request.files.add(await http.MultipartFile.fromPath("images", file.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        _showMessage("Folder uploaded successfully!");
      } else {
        _showMessage("Failed to upload folder. Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      _showMessage("Error uploading folder: $e");
    }
  }

  // Function to show messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Folder, Rename & Upload")),
      body: Column(
        children: [
          _selectedFolderPath != null
              ? Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text("Folder Path: $_selectedFolderPath",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                TextField(
                  controller: _folderNameController,
                  decoration: InputDecoration(
                    labelText: "Rename Folder",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          )
              : Container(),
          Expanded(
            child: _imageFiles.isNotEmpty
                ? GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Image.file(_imageFiles[index], fit: BoxFit.cover);
              },
            )
                : Center(
              child: Text(
                "No images found in the selected folder",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _pickFolder,
                  child: Text("Select Folder"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _uploadFolder,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Upload Folder"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
