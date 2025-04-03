import 'package:flutter/material.dart';
import 'package:trackin/loggin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added missing import

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isOrganization = true;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String password = "";
  String selectedOrganization = 'Organization'; // Default value

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _orgTypeController = TextEditingController();
  String? _selectedAssociatedOrg;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize with default value
    isOrganization = selectedOrganization == 'Organization';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _orgTypeController.dispose();
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
              Center(
                child: Text('Your Logo Here',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedOrganization,
                items: [
                  DropdownMenuItem(
                      value: 'Organization',
                      child: Text('Register as Organization')),
                  DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Register as Individual')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedOrganization = value;
                      isOrganization = value == 'Organization';
                    });
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Select Registration Type',
                    filled: true,
                    fillColor: Colors.grey[200]),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (isOrganization) ...[
                          buildTextField(_nameController, 'Organization Name',
                              'Enter organization name'),
                          buildTextField(
                              _orgTypeController, 'Organization Type',
                              'School, College, Company, etc.'),
                          buildTextField(_emailController, 'Email',
                              'Enter organization email', isEmail: true),
                          buildTextField(_phoneController, 'Phone Number',
                              'Enter organization phone'),
                        ] else
                          ...[
                            buildTextField(_nameController, 'Full Name',
                                'Enter full name'),
                            buildTextField(
                                _emailController, 'Email', 'Enter email',
                                isEmail: true),
                            buildTextField(_phoneController, 'Phone Number',
                                'Enter phone number'),
                            buildDropdownField('Associated Organization',
                                ['Org 1', 'Org 2', 'Org 3']),
                          ],
                        buildPasswordField(
                            _passwordController, 'Password', 'Enter password',
                            isConfirmField: false),
                        buildPasswordField(
                            _confirmPasswordController, 'Confirm Password',
                            'Confirm password', isConfirmField: true),
                        CheckboxListTile(
                          value: true,
                          onChanged: (val) {},
                          title: Text('I agree to the Terms and Conditions'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.black,
                              ),
                              child: Text(
                                isOrganization
                                    ? 'Register as Organization'
                                    : 'Register as Individual',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                        SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                children: [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      String hint,
      {bool isEmail = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiline ? 3 : 1,
        validator: (value) {
          if (value == null || value.isEmpty) return 'This field is required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
            return 'Enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label,
      String hint, {required bool isConfirmField}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
                isConfirmField
                    ? (obscureConfirmPassword ? Icons.visibility : Icons
                    .visibility_off)
                    : (obscurePassword ? Icons.visibility : Icons
                    .visibility_off)
            ),
            onPressed: () {
              setState(() {
                if (isConfirmField) {
                  obscureConfirmPassword = !obscureConfirmPassword;
                } else {
                  obscurePassword = !obscurePassword;
                }
              });
            },
          ),
        ),
        obscureText: isConfirmField ? obscureConfirmPassword : obscurePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Password is required';
          if (!isConfirmField) {
            password = value;
            // Check password strength
            if (value.length < 6)
              return 'Password must be at least 6 characters';
          }
          if (isConfirmField && value != _passwordController.text)
            return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        items: items.map((item) =>
            DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (value) {
          setState(() {
            _selectedAssociatedOrg = value;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null && !isOrganization)
            return 'Please select an organization';
          return null;
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // 1. Create user with Firebase Authentication
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // 2. Create the user document in Firestore
        await _saveUserDataToFirestore(userCredential.user!.uid);

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );

        // Navigate to login page after successful registration
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });

        String errorMessage = 'Registration failed. Please try again.';

        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for this email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveUserDataToFirestore(String userId) async {
    try {
      // Create a map of the user data to save
      Map<String, dynamic> userData = {
        'createdAt': FieldValue.serverTimestamp(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'userType': isOrganization ? 'organization' : 'individual',
      };

      // Add organization-specific or individual-specific fields
      if (isOrganization) {
        userData['organizationName'] = _nameController.text.trim();
        userData['organizationType'] = _orgTypeController.text.trim();
      } else {
        userData['fullName'] = _nameController.text.trim();
        userData['associatedOrganization'] = _selectedAssociatedOrg;
      }

      // Save to the appropriate collection based on user type
      String collection = isOrganization ? 'organizations' : 'individuals';
      String emailKey = _emailController.text.trim();

      // Use email as the document ID
      await _firestore.collection(collection).doc(emailKey).set(userData);

      // Also save a reference in the users collection
      await _firestore.collection('users').doc(emailKey).set({
        'userType': isOrganization ? 'organization' : 'individual',
        'referenceId': emailKey,
        'email': _emailController.text.trim(),
      });
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }
}