  import 'package:flutter/material.dart';
  import 'package:trackin/auth/loggin_page.dart';
  import 'package:trackin/faculty/faculty_dashboard.dart';
  import 'package:trackin/faculty/profile_page_faculty.dart';
  import 'package:trackin/faculty/take_attendence.dart';
  import 'package:trackin/faculty/view%20attendence.dart';

  import '../organization/add_student.dart';

  class IndividualHome extends StatefulWidget {
    const IndividualHome({super.key});

    @override
    _IndividualHomeState createState() => _IndividualHomeState();
  }

  class _IndividualHomeState extends State<IndividualHome> {
    int _selectedIndex = 0;

    final List<Widget> _pages = [
      FacultyDashboard(),
      AddStudentFacultyPage(),
      TakeAttendance(),
      ProfilePageFac()
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
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -1),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_outlined),
                activeIcon: Icon(Icons.add),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt_outlined),
                activeIcon: Icon(Icons.camera_alt),
                label: 'Take',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),

      );
    }
  }
