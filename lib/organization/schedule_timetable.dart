
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScheduleTimetable extends StatefulWidget {
  @override
  _ScheduleTimetableState createState() => _ScheduleTimetableState();
}

class _ScheduleTimetableState extends State<ScheduleTimetable> {
  String? selectedClass;
  String? selectedDay;
  bool noClasses = false;

  List<Map<String, TextEditingController>> rows = [];

  final List<String> classes = ['Class A', 'Class B', 'Class C'];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  void addRow() {
    if (selectedClass == null || selectedDay == null) return;
    setState(() {
      rows.add({
        'timing': TextEditingController(),
        'subject': TextEditingController(),
        'faculty': TextEditingController(),
      });
    });
  }

  void deleteRow(int index) {
    setState(() {
      rows.removeAt(index);
    });
  }

  void handleSubmit() {
    if (noClasses) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No classes scheduled.')));
      return;
    }

    for (var row in rows) {
      print("Timing: ${row['timing']!.text}, Subject: ${row['subject']!.text}, Faculty: ${row['faculty']!.text}");
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submitted successfully.')));
  }

  bool get isFormValid => selectedClass != null && selectedDay != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Timetable Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedClass,
                    hint: Text("Select Class"),
                    items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => selectedClass = val),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDay,
                    hint: Text("Select Day"),
                    items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDay = val),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // No Classes Checkbox
            Row(
              children: [
                Checkbox(
                  value: noClasses,
                  onChanged: (value) {
                    setState(() {
                      noClasses = value!;
                      if (noClasses) rows.clear();
                    });
                  },
                ),
                Text('No Classes'),
              ],
            ),

            if (!noClasses) ...[
              // Table Headings
              Row(
                children: const [
                  Expanded(child: Text('Timing', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(child: Text('Faculty', style: TextStyle(fontWeight: FontWeight.bold))),
                  SizedBox(width: 48),
                ],
              ),
              SizedBox(height: 8),

              // Row builder with + button just after the last row
              ...rows.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TextEditingController> row = entry.value;
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: row['timing'],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter Timing',
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: row['subject'],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter Subject',
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: row['faculty'],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Enter Faculty',
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteRow(index),
                          ),
                        ],
                      ),
                    ),
                    // Show + button only after the last row
                    if (index == rows.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: GestureDetector(
                          onTap: isFormValid ? addRow : null,
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFormValid ? Colors.black : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              color: isFormValid ? Colors.white : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: isFormValid ? Colors.black : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),

              // If no row yet, show + button directly
              if (rows.isEmpty)
                GestureDetector(
                  onTap: isFormValid ? addRow : null,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isFormValid ? Colors.black : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      color: isFormValid ? Colors.white : Colors.grey[300],
                    ),
                    child: Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 22,
                          color: isFormValid ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: handleSubmit,
                  child: Text("Submit"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
