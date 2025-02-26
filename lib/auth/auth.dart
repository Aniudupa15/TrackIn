import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trackin/home_page.dart';
import 'package:trackin/individual_page.dart';
import 'package:trackin/loggin_page.dart';
import 'package:trackin/organization_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoading = true;
  User? user;
  String? userRole;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? currentUser) async {
      if (mounted) {
        setState(() {
          user = currentUser;
        });
        if (user != null) {
          userRole = await getUserRole(user!.email!);
        }
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<String> getUserRole(String userEmail) async {
    try {
      DocumentSnapshot userRoleDoc =
      await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
      return userRoleDoc['userType'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user role: $e');
      }
      return '';
    }
  }

  Widget getHomePage() {
    if (user == null) {
      return  LoginPage(); // Redirect to LoginPage if the user is not logged in
    }
    switch (userRole) {
      case 'organization':
        return const OrganizationHome();
      case 'individual':
        return const IndividualHome();
      default:
        return const HomePage(); // Default page if role is undefined
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : getHomePage(),
    );
  }
}

// Placeholder home pages for different roles

