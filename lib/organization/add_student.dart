import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentFacultyPage extends StatefulWidget {
  const AddStudentFacultyPage({super.key});

  @override
  State<AddStudentFacultyPage> createState() => _AddStudentFacultyPageState();
}

class _AddStudentFacultyPageState extends State<AddStudentFacultyPage> {
  List<File> _imageFiles = [];
  String? _selectedFolderPath;
  final TextEditingController _folderNameController = TextEditingController();
  String orgName = "";
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrgName();
  }

  Future<void> _fetchOrgName() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          orgName = userDoc.data()?['Organization Name'] ?? "";
        });
      }
    } catch (e) {
      _showPopup("Error", "Failed to fetch organization name: $e");
    }
  }

  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showPopup("Permission Denied", "Storage permission is required!");
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
      _folderNameController.text = path.basename(selectedDirectory);
    });
  }

  List<File> _getImageFilesFromFolder(String dirPath) {
    final dir = Directory(dirPath);
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
      _showPopup("Error", "Please select a folder with images first.");
      return;
    }

    String folderName = _folderNameController.text.trim();
    if (folderName.isEmpty) {
      _showPopup("Error", "Folder name cannot be empty.");
      return;
    }

    if (orgName.isEmpty) {
      _showPopup("Error", "Organization name not found.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://aniudupa-trackin.hf.space/create_folder/"),
      );
      request.fields["folder_name"] = folderName;
      request.fields["org_name"] = orgName;

      for (var file in _imageFiles) {
        request.files
            .add(await http.MultipartFile.fromPath("files", file.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200) {
        _showPopup("Success", responseBody);

        final imageFileNames =
        _imageFiles.map((file) => path.basename(file.path)).toList();

        await _storeFolderInFirestore(folderName, imageFileNames);
      } else {
        _showPopup("Upload Failed", "Status: ${response.statusCode}\n$responseBody");
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showPopup("Error", "Upload failed: $e");
    }
  }
  Future<void> _storeFolderInFirestore(
      String folderName, List<String> imageFileNames) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showPopup("Auth Error", "User not logged in.");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final fullName = userDoc.data()?['fullName'] ?? '';
      if (fullName.isEmpty) {
        _showPopup("Error", "User full name not found.");
        return;
      }

      final studentsCollection = FirebaseFirestore.instance
          .collection(orgName)
          .doc(fullName)
          .collection('students');

      for (String imageName in imageFileNames) {
        final baseName = path.basenameWithoutExtension(imageName);
        await studentsCollection.doc(baseName).set({
          'image_name': imageName,
          'folder': folderName,
          'uploaded_at': FieldValue.serverTimestamp(),
        });
      }

      // Update folder_names array in the organization's document
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgName)
          .set({
        'folder_names': FieldValue.arrayUnion([folderName])
      }, SetOptions(merge: true));

    } catch (e) {
      _showPopup("Firestore Error", "Failed to store folder: $e");
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Add Students", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text("Select Folder"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedFolderPath != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Folder Details",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      Text("📁 Path: $_selectedFolderPath",
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _folderNameController,
                        decoration: InputDecoration(
                          labelText: "Folder Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (orgName.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text("🏢 Organization: $orgName",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Selected Images",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _imageFiles.isNotEmpty
                  ? GridView.builder(
                itemCount: _imageFiles.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFiles[i],
                        fit: BoxFit.cover),
                  );
                },
              )
                  : const Text("No images found."),
            ],
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _uploadFolder,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Upload Folder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
