import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignFacultyPage extends StatefulWidget {
  const AssignFacultyPage({Key? key}) : super(key: key);

  @override
  State<AssignFacultyPage> createState() => _AssignFacultyPageState();
}

class _AssignFacultyPageState extends State<AssignFacultyPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedFaculty;
  String? _selectedClass;
  String? _selectedSubject;

  List<String> _faculties = [];
  List<String> _classes = [];
  List<String> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    final facultySnapshot = await FirebaseFirestore.instance.collection('individual').get();
    final classSnapshot = await FirebaseFirestore.instance.collection('classes').get();
    final subjectSnapshot = await FirebaseFirestore.instance.collection('subjects').get();

    setState(() {
      _faculties = facultySnapshot.docs.map((doc) => doc['name'] as String).toList();
      _classes = classSnapshot.docs.map((doc) => doc['name'] as String).toList();
      _subjects = subjectSnapshot.docs.map((doc) => doc['subjectName'] as String).toList();
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('faculty_assignments').add({
        'faculty': _selectedFaculty,
        'class': _selectedClass,
        'subject': _selectedSubject,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully')),
      );

      setState(() {
        _selectedFaculty = null;
        _selectedClass = null;
        _selectedSubject = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Subject to Faculty')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _faculties.isEmpty || _classes.isEmpty || _subjects.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedFaculty,
                items: _faculties.map((faculty) {
                  return DropdownMenuItem<String>(
                    value: faculty,
                    child: Text(faculty),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Select Faculty'),
                onChanged: (value) {
                  setState(() {
                    _selectedFaculty = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a faculty' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedClass,
                items: _classes.map((cls) {
                  return DropdownMenuItem<String>(
                    value: cls,
                    child: Text(cls),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Select Class'),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a class' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSubject,
                items: _subjects.map((subj) {
                  return DropdownMenuItem<String>(
                    value: subj,
                    child: Text(subj),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Select Subject'),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
