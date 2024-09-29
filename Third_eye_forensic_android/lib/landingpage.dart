import 'package:flutter/material.dart';
import 'package:parsingprofile/parseoptions.dart';
import 'dart:math';

import 'package:parsingprofile/progressIndicator.dart';

class LandingpageScreen extends StatefulWidget {
  @override
  _LandingpageScreenState createState() => _LandingpageScreenState();
}

class _LandingpageScreenState extends State<LandingpageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..forward();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double radius = min(screenWidth, screenHeight) / 3.5;

    return Scaffold(
      body: Stack(
        children: [
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 65.0, bottom: 30.0),
              child: Container(
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 30, left: 20, right: 20, bottom: 25),
                      child: Image.asset(
                        'assets/images/nia_logo.png',
                        height: 120.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Select the app whose profile you want to parse",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 100.0),
                    Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 2.2 * radius,
                                height: 2.2 * radius,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade700,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: _rotationAnimation.value * 2 * pi,
                                child: Container(
                                  width: 2.2 * radius,
                                  height: 2.2 * radius,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      for (int i = 0; i < 6; i++)
                                        Transform.translate(
                                          offset: Offset(
                                            (radius - 5) * // Adjusted for spacing
                                                cos((i * pi / 3) +
                                                    (_rotationAnimation.value * 3 * pi)),
                                            (radius - 5) *
                                                sin((i * pi / 3) +
                                                    (_rotationAnimation.value * 3 * pi)),
                                          ),
                                          child: _buildAppIcon(i),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppIcon(int index) {
    final List<String> assetPaths = [
      'assets/images/instagram_logo.png',
      'assets/images/whatsapp_logo.png',
      'assets/images/linkedin_logo.png',
      'assets/images/gmail_logo.png',
      'assets/images/x_logo.png',
      'assets/images/facebook_logo.png',
    ];

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Instagram icon index
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ParsingOptionsScreen()),
          );
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          padding: EdgeInsets.all(10.0),
          child: Image.asset(
            assetPaths[index],
            height: 50.0,
            width: 50.0,
          ),
        ),
      ),
    );
  }
}
