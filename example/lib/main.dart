import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:image_editor/flutter_image_editor.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? _image;

  final picker = ImagePicker();

  Future<void> toImageEditor(File origin) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(
        originImage: origin,
      );
    })).then((result) {
      if (result is EditorImageResult) {
        setState(() {
          _image = result.newFile;
        });
      }
    }).catchError((er) {
      debugPrint(er);
    });
  }

  void getImage() async {
    PickedFile? image =
    await picker.getImage(source: ImageSource.gallery);
    if(image != null) {
      final File origin = File(image.path);
      toImageEditor(origin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: double.infinity, height: double.infinity,
        child: Column(
          children: [
            if(_image != null)
              Expanded(child: Image.file(_image!)),
            ElevatedButton(
              onPressed: getImage,
              child: Text('edit image'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget condition({required bool condtion, required Widget isTrue, required Widget isFalse}) {
  return condtion ? isTrue : isFalse;
}
