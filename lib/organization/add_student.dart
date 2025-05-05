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

  // Fetch the organization name from Firestore
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

  // Request storage permission on Android
  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showPopup("Permission Denied", "Storage permission is required!");
    }
    return status.isGranted;
  }

  // Pick a folder and list images from it
  Future<void> _pickFolder() async {
    if (!await _requestPermission()) return;

    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    setState(() {
      _selectedFolderPath = selectedDirectory;
      _imageFiles = _getImageFilesFromFolder(selectedDirectory);
      _folderNameController.text = path.basename(selectedDirectory); // Use alias for path
    });
  }

  // Get image files from the selected folder
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

  // Upload the folder and images, store in Firestore
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
      _isUploading = true; // Start the uploading indicator
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://aniudupa-trackin.hf.space/create_folder/"),
      );
      request.fields["folder_name"] = folderName;
      request.fields["org_name"] = orgName;

      for (var file in _imageFiles) {
        request.files.add(await http.MultipartFile.fromPath("files", file.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() {
        _isUploading = false; // Stop the uploading indicator
      });

      if (response.statusCode == 200) {
        _showPopup("Success", responseBody);

        // After successful upload, store the folder name in Firestore
        await _storeFolderInFirestore(folderName);
      } else {
        _showPopup("Upload Failed", "Status: ${response.statusCode}\n$responseBody");
      }
    } catch (e) {
      setState(() {
        _isUploading = false; // Stop the uploading indicator on error
      });
      _showPopup("Error", "Upload failed: $e");
    }
  }

  // Store folder name in Firestore under the organization
  Future<void> _storeFolderInFirestore(String folderName) async {
    try {
      // Reference to Firestore
      final orgRef = FirebaseFirestore.instance.collection('organizations').doc(orgName);
      final orgDoc = await orgRef.get();

      if (orgDoc.exists) {
        // Update the folder list if the document already exists
        List<dynamic> folderNames = List.from(orgDoc.data()?['folder_names'] ?? []);
        if (!folderNames.contains(folderName)) {
          folderNames.add(folderName); // Add new folder name
          await orgRef.update({'folder_names': folderNames});
        }
      } else {
        // Create a new document if it doesn't exist
        await orgRef.set({
          'folder_names': [folderName],
        });
      }
    } catch (e) {
      _showPopup("Firestore Error", "Failed to store folder: $e");
    }
  }

  // Show popup with title and message
  void _showPopup(String title, String message) {
    showDialog(
      context: context, // Correct BuildContext here
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Students",style: TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedFolderPath != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Folder Details",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Selected Images",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                    child: Image.file(_imageFiles[i], fit: BoxFit.cover),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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