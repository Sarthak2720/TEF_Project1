import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:parsingprofile/chatbot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import 'detectsuspicious.dart';

class PDFPage extends StatefulWidget {
  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  String pdfPath = '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final byteData = await rootBundle.load('assets/pdf/parseddata.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/parseddata.pdf');
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
          // Background image
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
                padding: const EdgeInsets.only(top: 65.0, bottom: 30.0, left: 16.0, right: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
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
                            Navigator.push(context,  MaterialPageRoute(
                                builder: (context) => suspiciousPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            'Detect Suspicious Activity',
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
          // Buttons with Icons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 36.0,
                    icon: Icon(Icons.share, color: Colors.black),
                    onPressed: () {
                      _sharePDF();
                    },
                  ),
                  IconButton(
                    iconSize: 36.0,
                    icon: Icon(Icons.download, color: Colors.black),
                    onPressed: () {
                      _downloadPDF();
                    },
                  ),
                  IconButton(
                    iconSize: 36.0,
                    icon: Icon(Icons.print, color: Colors.black),
                    onPressed: () {
                      _printPDF();
                    },
                  ),
                  IconButton(
                    iconSize: 36.0,
                    icon: Icon(Icons.chat, color: Colors.black),
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePDF() async {
    final pdfFile = File(pdfPath);
    if (pdfFile.existsSync()) {
      await Share.share('Check out this PDF: ${pdfFile.path}');
    }
  }

  Future<void> _downloadPDF() async {

  }

  Future<void> _printPDF() async {

  }
}
