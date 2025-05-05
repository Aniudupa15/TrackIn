import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackin/auth/register_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/img.png',
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TrackIn",
                        style: GoogleFonts.pacifico(
                          fontSize: 45,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Smart, Secure, Seamless \nAttendance",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Revolutionary AI-powered attendance\ntracking system for modern organizations.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacultyRegisterPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("Get Started", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Key Features",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _featureBox(Icons.tag_faces_rounded, "AI Facial", "Recognition"),
                  _featureBox(Icons.location_on, "Location", "Verification"),
                  _featureBox(Icons.security, "Secure", "Attendance"),
                ],
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Why Choose TrackIn?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _reasonTile(
              icon: Icons.check_circle,
              title: "Effortless Verification",
              subtitle: "Advanced AI technology ensures quick and accurate attendance tracking.",
            ),
            _reasonTile(
              icon: Icons.check_circle,
              title: "Real-time Monitoring",
              subtitle: "Track attendance status and generate reports instantly.",
            ),
            _reasonTile(
              icon: Icons.check_circle,
              title: "Enhanced Security",
              subtitle: "Prevent proxy attendance with multi-factor authentication.",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _featureBox(IconData icon, String line1, String line2) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black, size: 36),
          SizedBox(height: 5),
          Text(line1, textAlign: TextAlign.center),
          Text(line2, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _reasonTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
