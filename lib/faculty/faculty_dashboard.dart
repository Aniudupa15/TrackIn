import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class FacultyDashboard extends StatefulWidget {
  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  final int totalClasses = 10;
  final int classesTaken = 5;
  final double averageAttendance = 50.0;

  List<Map<String, String>> lowAttendanceList = [
    {'name': 'Ananya', 'subject': 'NLP', 'percent': '20%'},
  ];

  @override
  Widget build(BuildContext context) {
    double takenPercent = (classesTaken / totalClasses) * 100;
    double remainingPercent = 100 - takenPercent;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Column(
              children: [
                SizedBox(height: 10),
                Text(
                  'Classes - $classesTaken/$totalClasses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: takenPercent,
                          title: 'Taken',
                          radius: 60,
                          titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: remainingPercent,
                          title: 'Left',
                          radius: 60,
                          titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Pie chart for Average Attendance
            Column(
              children: [
                SizedBox(height: 10),
                Text(
                  'Avg Attendance - ${averageAttendance.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.orange,
                          value: averageAttendance,
                          title: '${averageAttendance.toInt()}%',
                          radius: 60,
                          titleStyle: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        PieChartSectionData(
                          color: Colors.grey,
                          value: 100 - averageAttendance,
                          title: '',
                          radius: 60,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Low Attendance Table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10), topRight: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Low Attendance',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                        children: [
                          tableCell('Name'),
                          tableCell('Subject'),
                          tableCell('%'),
                        ],
                      ),
                      ...lowAttendanceList.map((entry) {
                        return TableRow(
                          children: [
                            tableCell(entry['name']!),
                            tableCell(entry['subject']!),
                            tableCell(entry['percent']!),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text) => Padding(
    padding: EdgeInsets.all(8),
    child: Text(text, textAlign: TextAlign.center),
  );
}
