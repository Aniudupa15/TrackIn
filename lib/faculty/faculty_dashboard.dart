import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyDashboard extends StatefulWidget {
  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String orgName = "";
  String userName = "";
  int totalClasses = 0;
  double averageAttendance = 0.0;
  List<Map<String, dynamic>> lowAttendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Call the methods to fetch and process the data again
    await _fetchUserData(); // Refresh user data
    await _fetchDashboardData();    // Refresh faculty data

    setState(() {
      _isLoading = false;  // Hide loading indicator
    });
  }

  Future<void> _fetchUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            orgName = userDoc.data()?['Organization Name'] ?? "";
            userName = userDoc.data()?['fullName'] ?? "";
          });
          _fetchDashboardData();
        } else {
          _showPopup("Error", "User document does not contain valid data.");
          setState(() => _isLoading = false);
        }
      } catch (e) {
        _showPopup("Error", "Failed to fetch user data: $e");
        setState(() => _isLoading = false);
      }
    } else {
      _showPopup("Error", "User not logged in.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDashboardData() async {
    if (orgName.isEmpty || userName.isEmpty) {
      _showPopup("Error", "Organization name or username is empty.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get faculty data based on new schema
      final facultyRef = FirebaseFirestore.instance
          .collection(orgName)
          .doc(userName);
      final facultySnapshot = await facultyRef.get();

      if (facultySnapshot.exists && facultySnapshot.data() != null) {
        // Get class count from faculty document
        var classCountValue = facultySnapshot.data()?['class_count'];
        totalClasses = classCountValue is int ? classCountValue : 0;

        // Get students collection for this faculty
        final studentsSnapshot = await facultyRef.collection('students').get();
        final allStudents = studentsSnapshot.docs;

        int totalAttendanceSum = 0;
        int totalMissingClasses = 0;
        lowAttendanceList.clear();

        for (var doc in allStudents) {
          final data = doc.data();
          var attendanceValue = data['attendance_count'];
          int attendance = attendanceValue is int ? attendanceValue : 0;

          var missingClassesValue = data['classes_not_attended_count'];
          int missingClasses = missingClassesValue is int ? missingClassesValue : 0;

          String name = doc.id;

          totalAttendanceSum += attendance;
          totalMissingClasses += missingClasses;

          lowAttendanceList.add({
            'name': name,
            'attendance_count': attendance,
            'missing_classes': missingClasses
          });
        }

        // Sort by missing_classes (descending) to show students with more missed classes first
        lowAttendanceList.sort((a, b) => b['missing_classes'].compareTo(a['missing_classes']));


        // Calculate average attendance
        int studentCount = allStudents.length;
        if (totalClasses > 0 && studentCount > 0) {
          averageAttendance =
              (totalAttendanceSum.toDouble() / (totalClasses * studentCount)) * 100;

          if (averageAttendance.isNaN || averageAttendance.isInfinite) {
            averageAttendance = 0.0;
          }
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        _showPopup("Error", "No faculty data found.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showPopup("Error", "Failed to fetch dashboard data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text("OK")),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double takenPercent = averageAttendance;
    double remainingPercent = 100 - takenPercent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Trigger data refresh when pulled down
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total Classes Conducted',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalClasses',
                        style: const TextStyle(fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Overall Attendance',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: takenPercent,
                                title: '${takenPercent.toStringAsFixed(1)}%',
                                radius: 60,
                                titleStyle: const TextStyle(fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                color: Colors.red,
                                value: remainingPercent,
                                title: '${remainingPercent.toStringAsFixed(1)}%',
                                radius: 60,
                                titleStyle: const TextStyle(fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Attendance Status',
                          style: TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.grey),
                        defaultVerticalAlignment: TableCellVerticalAlignment
                            .middle,
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            children: [
                              tableCell('Name'),
                              tableCell('Classes Attended'),
                              tableCell('Classes Missed'),
                            ],
                          ),
                          ...lowAttendanceList.map((entry) {
                            return TableRow(
                              children: [
                                tableCell(entry['name']),
                                tableCell(entry['attendance_count'].toString()),
                                tableCell(entry['missing_classes'].toString()),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableCell(String text) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
}
