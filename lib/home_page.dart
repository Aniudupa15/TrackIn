import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackin/auth/register_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(children: [
              Image.asset(
                'assets/img.png',
              ),
              Column(
                children: [
                  SizedBox(
                    height: 75,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Row(
                      children: [
                        Text(
                          "TrackIn",
                          style: GoogleFonts.pacifico(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Row(
                      children: [
                        Text(
                          "Smart, Secure,Seamless \nAttendance ",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Row(
                      children: [
                        Text(
                          "Revolutionary AI-powered attendance\ntracking system for modern\norganizations",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      'Get Started',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(fixedSize: Size(200,50),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // <-- Radius
                      ),
                    ),
                  )
                ],
              ),
            ]),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      children: [
                        Text(
                          "Key Features",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.black12,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                Icons.tag_faces_rounded,
                                color: Colors.black,
                                size: 36.0,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("AI Facial"),
                              Text("Recognition")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.black12,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.black,
                                size: 36.0,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Location"),
                              Text("Verification")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.black12,
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.black,
                                size: 36.0,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Secure"),
                              Text("Attendance")
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      children: [
                        Text(
                          "Why Choose TrackIn?",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 25.0,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Effortless Verification",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ]),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 45,
                                      ),
                                      Text(
                                        "Advanced AI technology ensures quick \nand accurate attendance tracking",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(15),
                              child: Column(children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 25.0,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Real-time Monitoring",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 05,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 45,
                                    ),
                                    Text(
                                      "Track attendance status and generate \nreports instantly",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              color: Colors.black12,
                              padding: EdgeInsets.all(15),
                              child: Column(children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.black,
                                      size: 25.0,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Enhanced Security  ",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 05,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 45,
                                    ),
                                    Text(
                                      "Prevent proxy attendance with multi\nfactor authentication",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
