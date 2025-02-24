import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndividualHome extends StatelessWidget {
  const IndividualHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Individual Dashboard')),
      body: const Center(child: Text('Welcome, Individual!')),
    );
  }
}