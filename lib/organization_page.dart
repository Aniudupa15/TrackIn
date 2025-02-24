import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrganizationHome extends StatelessWidget {
  const OrganizationHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Dashboard')),
      body: const Center(child: Text('Welcome, Organization!')),
    );
  }
}
