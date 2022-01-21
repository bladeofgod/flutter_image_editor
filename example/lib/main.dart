import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:image_editor/image_editor.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> getimageditor(File origin) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(
        originImage: origin,
      );
    })).then((geteditimage) {
      if (geteditimage is EditorImageResult) {
        setState(() {
          _image = geteditimage.newFile;
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
      getimageditor(origin);
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
