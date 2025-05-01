import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackin/auth/loggin_page.dart';
import 'package:trackin/faculty/faculty_page.dart';

import '../faculty/faculty_dashboard.dart';

class FacultyRegisterPage extends StatefulWidget {
  @override
  _FacultyRegisterPageState createState() => _FacultyRegisterPageState();
}

class _FacultyRegisterPageState extends State<FacultyRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _employeeIdController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _selectedAssociatedOrg;
  List<String> _organizationList = [];

  @override
  void initState() {
    super.initState();
    fetchOrganizations();
  }

  Future<void> fetchOrganizations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('organization').get();
      setState(() {
        _organizationList = snapshot.docs.map((doc) => doc['orgName'] as String).toList();
      });
    } catch (e) {
      print('Error fetching organizations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading organization list')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Track-In Faculty Registration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(_nameController, 'Full Name', 'Enter full name'),
                        buildTextField(_emailController, 'Email', 'Enter email', isEmail: true),
                        buildTextField(_phoneController, 'Phone Number', 'Enter phone number'),
                        buildTextField(_employeeIdController, 'Employee ID', 'Enter employee ID'),
                        buildPasswordField(_passwordController, 'Password', 'Enter password', isConfirmField: false),
                        buildPasswordField(_confirmPasswordController, 'Confirm Password', 'Confirm password', isConfirmField: true),
                        SizedBox(height: 20),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, fontSize: 16),
                              children: [
                                TextSpan(text: "Already have an account? "),
                                TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, String hint, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label, String hint, {required bool isConfirmField}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isConfirmField ? obscureConfirmPassword : obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          suffixIcon: IconButton(
            icon: Icon(
              isConfirmField
                  ? (obscureConfirmPassword ? Icons.visibility : Icons.visibility_off)
                  : (obscurePassword ? Icons.visibility : Icons.visibility_off),
            ),
            onPressed: () {
              setState(() {
                if (isConfirmField)
                  obscureConfirmPassword = !obscureConfirmPassword;
                else
                  obscurePassword = !obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Password is required';
          if (!isConfirmField && value.length < 6) return 'Password must be at least 6 characters';
          if (isConfirmField && value != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (value) => setState(() => _selectedAssociatedOrg = value),
        value: _selectedAssociatedOrg,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please select an organization';
          return null;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _saveUserData(userCred.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful')),
      );

      // Navigate directly to Faculty Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IndividualHome()),
      );
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'weak-password' => 'The password provided is too weak.',
        'email-already-in-use' => 'An account already exists for this email.',
        'invalid-email' => 'The email address is not valid.',
        _ => 'Error: ${e.message}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveUserData(String userId) async {
    Map<String, dynamic> userData = {
      'uid': userId,
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'userType': 'faculty',
      'fullName': _nameController.text.trim(),
      'employeeId': _employeeIdController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).set(userData);
  }
}
