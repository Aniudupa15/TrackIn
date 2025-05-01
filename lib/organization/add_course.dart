import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({super.key});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _creditsController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addSubject() async {
    String name = _subjectNameController.text.trim();
    String code = _courseCodeController.text.trim();
    String credits = _creditsController.text.trim();

    if (name.isEmpty || code.isEmpty || credits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      await _firestore.collection("subjects").doc(name).set({
        "subjectName": name,
        "courseCode": code,
        "credits": int.parse(credits),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subject added successfully")),
      );

      _subjectNameController.clear();
      _courseCodeController.clear();
      _creditsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Subject")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectNameController,
              decoration: const InputDecoration(labelText: "Subject Name"),
            ),
            TextField(
              controller: _courseCodeController,
              decoration: const InputDecoration(labelText: "Course Code"),
            ),
            TextField(
              controller: _creditsController,
              decoration: const InputDecoration(labelText: "Credits"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSubject,
              child: const Text("Add Subject"),
            ),
          ],
        ),
      ),
    );
  }
}
