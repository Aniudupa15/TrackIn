
import 'package:flutter/material.dart';
import 'package:trackin/register_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'logo',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back! Please login to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: Icon(Icons.visibility_off),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        Text('Remember me'),
                      ],
                    ),
                    InkWell(
                      onTap: () {}, // Forgot password logic
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {}, // Login logic
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Or continue with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton('assets/google.png', onTap: () {}),
                    SizedBox(width: 16),
                    _socialButton('assets/apple.png', onTap: () {}),
                    SizedBox(width: 16),
                    _socialButton('assets/facebook.png', onTap: () {}),
                  ],
                ),
                SizedBox(height: 24),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  }, // Navigate to signup
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Terms of Service'),
                    SizedBox(width: 16),
                    Text('Privacy Policy'),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String assetPath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(assetPath, width: 24),
        ),
      ),
    );
  }
}