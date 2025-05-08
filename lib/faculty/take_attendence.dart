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
      }
    } catch (e) {
      _isLoadingOrgName = false;
      _showPopup("Error", "Failed to fetch organization name: $e");
    }
  }

  Stream<List<String>> get folderStream {
    return FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgName)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null && data.containsKey('folder_names')) {
        return List<String>.from(data['folder_names']);
      }
      return [];
    });
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

      final facultyRef = FirebaseFirestore.instance
          .collection(orgName)
          .doc(userName);

      // Update class count
      final facultySnapshot = await facultyRef.get();
      int classCount = (facultySnapshot.data()?['class_count'] ?? 0) + 1;
      if (facultySnapshot.exists) {
        await facultyRef.update({'class_count': classCount});
      } else {
        await facultyRef.set({'class_count': classCount});
      }

      // Get all students under faculty
      final allStudentsSnapshot = await facultyRef.collection('students').get();
      final allStudentIds = allStudentsSnapshot.docs.map((doc) => doc.id).toList();

      // Derive present students
      final presentStudents = allStudentIds.where((id) => !missingStudents.contains(id)).toList();

      // Handle missing (absent) students
      for (String student in missingStudents) {
        final studentRef = facultyRef.collection('students').doc(student);
        final studentSnapshot = await studentRef.get();

        if (studentSnapshot.exists) {
          int currentAbsences = studentSnapshot.data()?['classes_not_attended_count'] ?? 0;
          int currentAttendance = studentSnapshot.data()?['attendance_count'] ?? 0;
          await studentRef.update({
            'attendance_count': currentAttendance + 1,
            'classes_not_attended_count': currentAbsences + 1,
          });
        } else {
          await studentRef.set({
            'attendance_count': 1,
            'classes_not_attended_count': 1,
          });
        }
      }

      // Handle present students
      for (String student in presentStudents) {
        final studentRef = facultyRef.collection('students').doc(student);
        final studentSnapshot = await studentRef.get();

        if (studentSnapshot.exists) {
          int currentAttendance = studentSnapshot.data()?['attendance_count'] ?? 0;
          await studentRef.update({
            'attendance_count': currentAttendance + 1,
          });
        } else {
          await studentRef.set({
            'attendance_count': 1,
            'classes_not_attended_count': 0,
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
              if (_isLoadingOrgName)
                const CircularProgressIndicator()
              else if (orgName.isEmpty)
                const Text("Organization not found.")
              else
                StreamBuilder<List<String>>(
                  stream: folderStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text("Error loading folders.");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No folders available.");
                    } else {
                      final folders = snapshot.data!;
                      if (!_folderNames.contains(_selectedFolder)) {
                        _selectedFolder = folders.first;
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Folder",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedFolder,
                        items: folders.map((folder) {
                          return DropdownMenuItem<String>(
                            value: folder,
                            child: Text(folder),
                          );
                        }).toList(),
                        onChanged: (newFolder) {
                          setState(() {
                            _selectedFolder = newFolder;
                            _folderNames = folders;
                          });
                        },
                      );
                    }
                  },
                ),

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
