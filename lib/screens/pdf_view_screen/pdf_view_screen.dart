import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class PdfView extends StatefulWidget {
  String htmlContent;
  PdfView(this.htmlContent);
  @override
  _PdfViewState createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  String generatedPdfFilePath;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  PDFDocument document;

  @override
  void initState() {
    super.initState();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: selectNotification);

    generateExampleDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Share.shareFiles([generatedPdfFilePath]);
              },
              child: Text("Share"))
        ],
      ),
      body: document != null
          ? Center(child: PDFViewer(document: document))
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generateExampleDocument();
          _showNotification();
        },
        tooltip: 'Download',
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future<void> _download() async {
    // download
    final dir = await _getDownloadDirectory();
    final isPermissionStatusGranted = await _requestPermissions();

    if (isPermissionStatusGranted) {
      await File(generatedPdfFilePath).create(recursive: true);
      _showNotification();
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // return await DownloadsPathProvider.downloadsDirectory as Directory;
      return await getExternalStorageDirectory().then((value) => value);
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user

    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      await Permission.storage.request();
    }
    return status == PermissionStatus.granted;
  }

  Future selectNotification(String payload) async {
    //Handle notification tapped logic here
  }

  Future<void> _showNotification() async {
    final android = AndroidNotificationDetails(
        'channel id', 'channel name', 'channel description',
        priority: Priority.high, importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);

    final isSuccess = true;

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      isSuccess ? 'Success' : 'Failure',
      isSuccess
          ? 'File has been downloaded successfully!'
          : 'There was an error while downloading the file.',
      platform,
    );
  }

  Future<void> generateExampleDocument() async {
    Directory appDocDir = await _getDownloadDirectory();
    final targetPath = appDocDir.path;
    final targetFileName = "example-pdf";

    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        widget.htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;
    document = await PDFDocument.fromFile(File(generatedPdfFilePath));

    setState(() {});
  }
}
