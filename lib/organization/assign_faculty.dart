import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignFacultyPage extends StatelessWidget {
  final TextEditingController orgNameController = TextEditingController();
  final TextEditingController folderNameController = TextEditingController();
  final TextEditingController facultyIdController = TextEditingController();

  // Function to send POST request to assign faculty
  Future<void> _assignFaculty(BuildContext context) async {
    var response = await http.post(
      Uri.parse('http://localhost:8000/assign_faculty/'),
      body: {
        'org_name': orgNameController.text,
        'folder_name': folderNameController.text,
        'faculty_id': facultyIdController.text,
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Faculty assigned successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to assign faculty")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Faculty')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: orgNameController,
              decoration: InputDecoration(labelText: 'Organization Name'),
            ),
            TextField(
              controller: folderNameController,
              decoration: InputDecoration(labelText: 'Folder Name'),
            ),
            TextField(
              controller: facultyIdController,
              decoration: InputDecoration(labelText: 'Faculty ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _assignFaculty(context),
              child: Text('Assign Faculty'),
            ),
          ],
        ),
      ),
    );
  }
}
