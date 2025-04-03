import 'package:flutter/material.dart';
import 'package:trackin/loggin_page.dart';

class IndividualHome extends StatefulWidget {
  const IndividualHome({super.key});

  @override
  _IndividualHomeState createState() => _IndividualHomeState();
}

class _IndividualHomeState extends State<IndividualHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Dashboard Content')),
    const Center(child: Text('Add Faculty & Student Photo PDF')),
    const Center(child: Text('Schedule Classes')),
    const Center(child: Text('Profile Information')),
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
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'Add PDF'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}