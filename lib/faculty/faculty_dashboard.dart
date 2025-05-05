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
  int totalClasses = 0;
  double averageAttendance = 0.0;
  List<Map<String, dynamic>> lowAttendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrgName();
  }

  Future<void> _fetchOrgName() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          orgName = userDoc.data()?['Organization Name'] ?? "";
          _fetchDashboardData();
        } else {
          _showPopup("Error", "User document does not contain valid data.");
          setState(() => _isLoading = false);
        }
      } catch (e) {
        _showPopup("Error", "Failed to fetch organization name: $e");
        setState(() => _isLoading = false);
      }
    } else {
      _showPopup("Error", "User not logged in.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDashboardData() async {
    if (orgName.isEmpty) {
      _showPopup("Error", "Organization name is empty.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final orgRef = FirebaseFirestore.instance.collection('organizations').doc(
          orgName);
      final orgSnapshot = await orgRef.get();

      if (orgSnapshot.exists && orgSnapshot.data() != null) {
        totalClasses = orgSnapshot.data()?['class_count'] ?? 0;

        final studentsSnapshot = await orgRef.collection('students').get();
        final allStudents = studentsSnapshot.docs;

        int totalAttendanceSum = 0;
        lowAttendanceList.clear();

        for (var doc in allStudents) {
          final data = doc.data();
          int attendance = data['attendance_count'] ?? 0;
          String name = data['name'] ?? 'Unknown';

          totalAttendanceSum += attendance;

          if (attendance >= 2) {
            lowAttendanceList.add({
              'name': name,
              'attendance_count': attendance,
            });
          }
        }

        // Sort and limit to top 3
        lowAttendanceList.sort((a, b) =>
            a['attendance_count'].compareTo(b['attendance_count']));
        if (lowAttendanceList.length > 3) {
          lowAttendanceList = lowAttendanceList.take(3).toList();
        }

        // Calculate average attendance
        int studentCount = allStudents.length;
        if (totalClasses > 0 && studentCount > 0) {
          averageAttendance =
              (totalAttendanceSum / (totalClasses * studentCount)) * 100;
        }

        // Save low attendance data to Firestore
        await _saveLowAttendanceData();

        setState(() {
          _isLoading = false;
        });
      } else {
        _showPopup("Error", "No organization data found.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showPopup("Error", "Failed to fetch dashboard data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLowAttendanceData() async {
    if (lowAttendanceList.isNotEmpty) {
      try {
        final orgRef = FirebaseFirestore.instance
            .collection('organizations')
            .doc(orgName);

        for (var student in lowAttendanceList) {
          final studentRef = orgRef.collection("students").doc(student['name']);

          await studentRef.set({
            'name': student['name'],
            'attendance_count': student['attendance_count'],
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        _showPopup("Error", "Failed to save low attendance data: $e");
      }
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
        title: const Text("Faculty Dashboard",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
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
                        'Low Attendance (Top 3)',
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
                          ],
                        ),
                        ...lowAttendanceList.map((entry) {
                          return TableRow(
                            children: [
                              tableCell(entry['name']),
                              tableCell(entry['attendance_count'].toString()),
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