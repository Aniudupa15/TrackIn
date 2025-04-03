import 'package:flutter/material.dart';
import 'package:trackin/auth/loggin_page.dart';
import 'package:trackin/faculty/faculty_dashboard.dart';
import 'package:trackin/faculty/profile_page_faculty.dart';
import 'package:trackin/faculty/take_attendence.dart';
import 'package:trackin/faculty/view%20attendence.dart';

class IndividualHome extends StatefulWidget {
  const IndividualHome({super.key});

  @override
  _IndividualHomeState createState() => _IndividualHomeState();
}

class _IndividualHomeState extends State<IndividualHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FacultyDashboard(),
    ViewAttendance(),
    TakeAttendence(),
    const ProfilePageFac()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Individual Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'View Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Take Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}