import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class AddStudentFacultyPage extends StatefulWidget {
  const AddStudentFacultyPage({super.key});

  @override
  State<AddStudentFacultyPage> createState() => _AddStudentFacultyPageState();
}

class _AddStudentFacultyPageState extends State<AddStudentFacultyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<File> _imageFiles = [];
  String? _selectedFolderPath;
  final TextEditingController _folderNameController = TextEditingController();

  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showMessage("Storage permission is required!");
    }
    return status.isGranted;
  }

  Future<void> _pickFolder() async {
    if (!await _requestPermission()) return;

    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    setState(() {
      _selectedFolderPath = selectedDirectory;
      _imageFiles = _getImageFilesFromFolder(selectedDirectory);
      _folderNameController.text = basename(selectedDirectory);
    });
  }

  List<File> _getImageFilesFromFolder(String path) {
    final dir = Directory(path);
    return dir.existsSync()
        ? dir
        .listSync()
        .where((f) =>
    f is File &&
        (f.path.endsWith(".jpg") ||
            f.path.endsWith(".jpeg") ||
            f.path.endsWith(".png")))
        .map((f) => File(f.path))
        .toList()
        : [];
  }

  Future<void> _uploadFolder() async {
    if (_selectedFolderPath == null || _imageFiles.isEmpty) {
      _showMessage("Please select a folder first!");
      return;
    }

    String folderName = _folderNameController.text.trim();
    if (folderName.isEmpty) {
      _showMessage("Folder name cannot be empty!");
      return;
    }

    var request = http.MultipartRequest("POST", Uri.parse("https://your-api.com/upload"));
    request.fields["folder_name"] = folderName;

    for (var file in _imageFiles) {
      request.files.add(await http.MultipartFile.fromPath("images", file.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      _showMessage("Folder uploaded successfully!");
    } else {
      _showMessage("Upload failed: ${response.reasonPhrase}");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context as BuildContext
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_selectedFolderPath != null)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected Folder: $_selectedFolderPath", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _folderNameController,
                    decoration: const InputDecoration(labelText: "Rename Folder"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _imageFiles.isNotEmpty
                ? GridView.builder(
              itemCount: _imageFiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (_, i) => Image.file(_imageFiles[i], fit: BoxFit.cover),
            )
                : const Center(child: Text("No images found")),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _pickFolder, child: const Text("Select Folder")),
                ElevatedButton(
                  onPressed: _uploadFolder,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Upload"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
