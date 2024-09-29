import 'package:flutter/material.dart';
import 'package:parsingprofile/progressIndicator.dart';

class ParsingOptionsScreen extends StatefulWidget {
  ParsingOptionsScreen();

  @override
  _ParsingOptionsScreenState createState() => _ParsingOptionsScreenState();
}

class _ParsingOptionsScreenState extends State<ParsingOptionsScreen> {
  String? _selectedOption;

  final List<String> _options = [
    'Parse Everything',
    'Parse Posts',
    'Parse Chats',
    'Parse Comments',
    'Parse Liked Posts'
  ];

  @override
  Widget build(BuildContext context) {
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
                width: MediaQuery.of(context).size.width * 0.9,
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
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 10, right: 20, bottom: 25),
                            child: Image.asset(
                              'assets/images/nia_logo.png',
                              height: 120.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Center(
                          child: Text(
                            "What would you like to parse?",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _options.length,
                            itemBuilder: (context, index) {
                              return RadioListTile<String>(
                                title: Text(_options[index]),
                                value: _options[index],
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 8),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                textStyle: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w400),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18))),
                            onPressed: _selectedOption != null
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProgressScreen()),
                              );
                            }
                                : null,

                            child: Text("Parse"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
