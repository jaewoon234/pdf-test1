import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // 이미지 선택
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // PDF 생성 및 저장
  Future<String> _createPdf() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      _image!.readAsBytesSync(),
    );

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(_textController.text),
            pw.Image(image),
          ],
        );
      },
    ));

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // PDF 공유
  void _sharePdf(String path) async {
    Share.shareFiles([path]);
  }

  // PDF 열기
  void _openPdf(String path) async {
    OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF 예제'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('이미지 선택'),
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(hintText: '여기에 텍스트 입력'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_image != null && _textController.text.isNotEmpty) {
                  final path = await _createPdf();
                  _sharePdf(path);
                }
              },
              child: Text('PDF 생성 및 공유'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_image != null && _textController.text.isNotEmpty) {
                  final path = await _createPdf();
                  _openPdf(path);
                }
              },
              child: Text('PDF 생성 및 열기'),
            ),
          ],
        ),
      ),
    );
  }
}
