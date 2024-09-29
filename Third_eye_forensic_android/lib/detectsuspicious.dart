import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:parsingprofile/chatbot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class suspiciousPage extends StatefulWidget {
  @override
  _suspiciousPageState createState() => _suspiciousPageState();
}

class _suspiciousPageState extends State<suspiciousPage> {
  String pdfPath = '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final byteData = await rootBundle.load('assets/pdf/suspicious.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/suspicious.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    setState(() {
      pdfPath = file.path;
    });
  }

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
          // PDF view with button
          if (pdfPath.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 105.0, bottom: 30.0, left: 26.0, right: 26.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  // Adding border radius
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      // Adding border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4), // Shadow position
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            'Suspicious Activity Detected!!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: PDFView(
                            filePath: pdfPath,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (pdfPath.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            ),


        ],
      ),
    );
  }
}
