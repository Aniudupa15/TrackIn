import 'package:flutter/material.dart';
import 'package:trackin/auth/loggin_page.dart';
import 'package:trackin/organization/add_student.dart';
import 'package:trackin/organization/assign_faculty.dart';
import 'package:trackin/organization/organization_dashboard_page.dart';
import 'package:trackin/organization/profile_page_organization.dart';
import 'package:trackin/organization/schedule_timetable.dart';

class OrganizationHome extends StatefulWidget {
  const OrganizationHome({super.key});

  @override
  _OrganizationHomeState createState() => _OrganizationHomeState();
}

class _OrganizationHomeState extends State<OrganizationHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    AddStudentFacultyPage(),
    AssignFacultyPage(),
    ScheduleTimetable(),
    ProfilePageOrg(),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: 'Assign'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
