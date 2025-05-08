import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class TakeAttendance extends StatefulWidget {
  const TakeAttendance({super.key});

  @override
  State<TakeAttendance> createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends State<TakeAttendance> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _selectedFolder;
  List<String> _folderNames = [];
  String orgName = "";
  bool _isLoadingFolders = true;
  bool _isLoadingOrgName = true;
  bool _isUploading = false;

  var userName;

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
          _isLoadingOrgName = false;
        });
        _fetchFolderNames();
      }
    } catch (e) {
      _isLoadingOrgName = false;
      _showPopup("Error", "Failed to fetch organization name: $e");
    }
  }

  Future<void> _fetchFolderNames() async {
    if (orgName.isEmpty) {
      setState(() => _isLoadingFolders = false);
      return;
    }

    setState(() => _isLoadingFolders = true);

    try {
      final orgRef = FirebaseFirestore.instance.collection('organizations').doc(orgName);
      final snapshot = await orgRef.get();

      if (snapshot.exists) {
        final folderList = List<String>.from(snapshot.data()?['folder_names'] ?? []);
        setState(() {
          _folderNames = folderList;
          _isLoadingFolders = false;
          if (_folderNames.isNotEmpty) _selectedFolder = _folderNames[0];
        });
      } else {
        _isLoadingFolders = false;
        _showPopup("Error", "No folders found for this organization.");
      }
    } catch (e) {
      _isLoadingFolders = false;
      _showPopup("Error", "Failed to fetch folder names: $e");
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
      });
    }
  }

  Future<void> _submitPhoto() async {
    if (_image == null || _selectedFolder == null) {
      _showPopup("Error", "Please take a photo and select a folder first!");
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://aniudupa-trackin.hf.space/check_attendance/"),
      );
      request.fields["org_name"] = orgName;
      request.fields["folder_name"] = _selectedFolder!;
      request.files.add(await http.MultipartFile.fromPath("file", _image!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(responseBody);
        List<String> missingStudents = List<String>.from(responseMap['missing_students'] ?? []);
        await _updateAttendance(missingStudents);

        String missingList = missingStudents.isEmpty
            ? "All students are present."
            : "Missing students:\n${missingStudents.join("\n")}";
        _showPopup("Attendance Processed", missingList);
      } else {
        _showPopup("Failed", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showPopup("Error", "Upload failed: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateAttendance(List<String> missingStudents) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        userName = userDoc.data()?['fullName'] ?? "N/A";
      }

      // Update class count for faculty
      final facultyRef = FirebaseFirestore.instance
          .collection(orgName)
          .doc(userName);

      final facultySnapshot = await facultyRef.get();
      int classCount = 0;

      if (facultySnapshot.exists) {
        classCount = (facultySnapshot.data()?['class_count'] ?? 0) + 1;
        await facultyRef.update({'class_count': classCount});
      } else {
        classCount = 1;
        await facultyRef.set({'class_count': classCount});
      }

      // Update attendance for each missing student
      for (String student in missingStudents) {
        final studentRef = facultyRef.collection('students').doc(student);
        final studentSnapshot = await studentRef.get();

        if (studentSnapshot.exists) {
          int currentAbsences = studentSnapshot.data()?['classes_not_attended_count'] ?? 0;
          await studentRef.update({
            'attendance_count': studentSnapshot.data()?['attendance_count'] ?? 0 + 1,
            'classes_not_attended_count': currentAbsences + 1,
          });
        } else {
          await studentRef.set({
            'attendance_count': 1,
            'classes_not_attended_count': 1,
          });
        }
      }
    } catch (e) {
      _showPopup("Error", "Failed to update records: $e");
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.deepOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Folder",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedFolder,
      items: _folderNames.map((folder) {
        return DropdownMenuItem<String>(
          value: folder,
          child: Text(folder),
        );
      }).toList(),
      onChanged: (newFolder) {
        setState(() {
          _selectedFolder = newFolder;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              if (_isLoadingOrgName || _isLoadingFolders)
                const CircularProgressIndicator()
              else if (_folderNames.isEmpty)
                const Text("No folders available.", style: TextStyle(fontSize: 16))
              else
                _buildDropdown(),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Capture Photo", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              _image != null
                  ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(_image!.path), height: 200),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _submitPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text("Upload & Process"),
                    ),
                  ),
                ],
              )
                  : const Text("No photo taken yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}