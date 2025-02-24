import 'package:flutter/material.dart';
import 'package:trackin/loggin_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isOrganization = true;
  bool isLoading = false;
  bool obscurePassword = true;
  String password = "";
  String? selectedOrganization;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text('Your Logo Here',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedOrganization,
              items: [
                DropdownMenuItem(
                    value: 'Organization',
                    child: Text('Register as Organization')),
                DropdownMenuItem(
                    value: 'Individual', child: Text('Register as Individual')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedOrganization = value;
                  isOrganization = value == 'Organization';
                });
              },
              decoration: InputDecoration(
                  labelText: 'Select Registration Type',
                  filled: true,
                  fillColor: Colors.grey[200]),
            ),
            if (selectedOrganization == null) ...[
              SizedBox(height: 10),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }, // Navigate to signup
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
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
            if (selectedOrganization != null) ...[
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (isOrganization) ...[
                          buildTextField('Organization Name', 'Enter organization name'),
                          buildTextField('Organization Type', 'School, College, Company, etc.'),
                          buildTextField('Email', 'Enter organization email', isEmail: true),
                          buildTextField('Phone Number', 'Enter organization phone'),
                        ] else ...[
                          buildTextField('Full Name', 'Enter full name'),
                          buildTextField('Email', 'Enter email', isEmail: true),
                          buildTextField('Phone Number', 'Enter phone number'),
                          buildDropdownField('Associated Organization', ['Org 1', 'Org 2', 'Org 3']),
                        ],
                        buildPasswordField('Password', 'Enter password'),
                        buildPasswordField('Confirm Password', 'Confirm password', isConfirm: true),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            }, // Navigate to signup
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.black, fontSize: 16),
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
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      {bool isEmail = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
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

  Widget buildPasswordField(String label, String hint, {bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: IconButton(
            icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
        ),
        obscureText: obscurePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Password is required';
          if (!isConfirm) password = value;
          if (isConfirm && value != password) return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );
      });
    }
  }
}
Widget buildDropdownField(String label, List<String> items) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
      ),
    ),
  );
}
