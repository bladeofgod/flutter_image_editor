# image_editor

A high-performance image editor with crop, scribble, mosaic, add-text, flip, rotated functions.

Support custom ui style.

## Getting Started

First, add image_editor: as a 
[dependency in your pubspec.yaml file.](https://flutter.cn/development/packages-and-plugins/using-packages)

import
```
import 'package:image_editor/flutter_image_editor.dart';
```

iOS 
Add the following keys to your Info.plist file, located in <project root>/ios/Runner/Info.plist:

- NSPhotoLibraryUsageDescription - describe why your app needs permission for the photo library. This is called Privacy - Photo Library Usage Description in the visual editor.
- NSCameraUsageDescription - describe why your app needs access to the camera. This is called Privacy - Camera Usage Description in the visual editor.
- NSMicrophoneUsageDescription - describe why your app needs access to the microphone, if you intend to record videos. This is called Privacy - Microphone Usage Description in the visual editor.
Or in text format add the key:
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSCameraUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture audio for image picker plugin</string>
```

Android

No configuration required - the plugin should work out of the box.

## Usage

pick an image that wanna edit, and pass it to image editor like this:

```
  Future<void> toImageEditor(File origin) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageEditor(
        originImage: origin,
        //this is nullable, you can custom new file's save postion
        savePath: customDirectory
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
```

## custom ui style

You can extends ImageEditorDelegate and custom editor's widget:

```
ImageEditor.uiDelegate = YouUiDelegate();

class YouUiDelegate extends ImageEditorDelegate{
    ...
}
```


