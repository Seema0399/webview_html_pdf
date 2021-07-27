import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_project/screens/pdf_view_screen/pdf_view_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoadHtmlView extends StatefulWidget {
  @override
  _LoadHtmlViewState createState() => _LoadHtmlViewState();
}

class _LoadHtmlViewState extends State<LoadHtmlView> {
  double progressPercentage = 0;
  bool loaded = false;
  String htmlContent;

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController webViewController;
  String generatedPdfFilePath;
  @override
  void initState() {
    super.initState();
    getFileData("assets/test.html").then((value) => htmlContent = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Webview'),
        actions: [
          Center(
            child: Container(
              margin: EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () {},
                child: Text('Next'),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialFile: "assets/test.html",
                  onProgressChanged: (controller, percentage) {
                    setState(() {
                      progressPercentage = percentage / 100;
                      if (progressPercentage == 1) {
                        loaded = true;
                      }
                    });
                  },
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStop: (controller, url) async {
                    webViewController = controller;
                  },
                ),
                Visibility(
                  visible: !loaded,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    value: progressPercentage,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: Center(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfView(htmlContent)));
                  },
                  child: Text('Change to PDF')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await webViewController.evaluateJavascript(
              source:
                  'value("Seema S", "seemasenthil399@gamil.com", "Female")');
          htmlContent = await webViewController.getHtml();
        },
      ),
    );
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }
}
