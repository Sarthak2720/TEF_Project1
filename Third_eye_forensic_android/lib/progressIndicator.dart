import 'package:flutter/material.dart';
import 'dart:async';

import 'package:parsingprofile/pdfpage.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    startProgress();
  }

  void startProgress() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        progress += 0.02;
      });

      if (progress >= 1.0) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PDFPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.grey.withOpacity(0.5),
                  BlendMode.srcOver,
                ),
              ),
            ),
          ),
          // Progress Indicator and Percentage
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.blue,
                  value: progress,
                  strokeWidth: 8.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  "${(progress * 100).toInt()}%", // Display percentage
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color:
                        Colors.black, // Make text color visible on background
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
