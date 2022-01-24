

import 'package:flutter/material.dart';
import 'package:image_editor/flutter_image_editor.dart';
import 'package:image_editor/widget/text_editor_page.dart';

import 'editor_panel_controller.dart';


class DefaultTextConfigModel extends TextConfigModel{
  @override
  double get initSize => 14;

  @override
  double get sliderBottomLimit => 14;

  @override
  double get sliderUpLimit => 36;

}

class DefaultImageEditorDelegate extends ImageEditorDelegate{

  Color operatorStatuscolor(bool choosen) => choosen ? Colors.red : Colors.white;

  @override
  Widget addTextWidget(double limitSize, OperateType type, {required bool choosen}) {
    // TODO: implement addTextWidget
    throw UnimplementedError();
  }

  @override
  Widget backBtnWidget(double limitSize) {
    // TODO: implement backBtnWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement brushColors
  List<Color> get brushColors => throw UnimplementedError();

  @override
  Widget brushWidget(double limitSize, OperateType type, {required bool choosen}) {
    // TODO: implement brushWidget
    throw UnimplementedError();
  }

  @override
  Widget doneWidget(BoxConstraints constraints) {
    // TODO: implement doneWidget
    throw UnimplementedError();
  }

  @override
  Widget flipWidget(double limitSize, OperateType type, {required bool choosen}) {
    // TODO: implement flipWidget
    throw UnimplementedError();
  }

  @override
  Widget mosaicWidget(double limitSize, OperateType type, {required bool choosen}) {
    // TODO: implement mosaicWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement resetWidget
  Widget get resetWidget => throw UnimplementedError();

  @override
  Widget rotateWidget(double limitSize, OperateType type, {required bool choosen}) {
    // TODO: implement rotateWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement sliderThemeData
  SliderThemeData get sliderThemeData => throw UnimplementedError();

  @override
  // TODO: implement textColors
  List<Color> get textColors => throw UnimplementedError();

  @override
  // TODO: implement textConfigModel
  TextConfigModel get textConfigModel => throw UnimplementedError();

  @override
  // TODO: implement textSelectedBorder
  Border get textSelectedBorder => throw UnimplementedError();

  @override
  Widget undoWidget(double limitSize) {
    // TODO: implement undoWidget
    throw UnimplementedError();
  }


}


///This model for [TextEditorPage] to initial text style.
abstract class TextConfigModel{
  ///slider up limit
  double get sliderUpLimit;

  ///slider bottom limit
  double get sliderBottomLimit;

  ///initial size
  double get initSize;
}


///For delegate [ImageEditor]'s ui style.
abstract class ImageEditorDelegate{

  final BoxConstraints _doneWidgetCons = BoxConstraints(maxHeight: 32, maxWidth: 54);

  final double _operateBtnSize = 24;

  final double _unDoWidgetSize = 20;

  final double _backWidgetSize = 22;

  Widget buildDoneWidget() => doneWidget(_doneWidgetCons);

  Widget buildOperateWidget(OperateType type, {required bool choosen}) {
    switch(type) {
      case OperateType.non:
        return SizedBox();
      case OperateType.brush:
        return brushWidget(_operateBtnSize, type, choosen: choosen);
      case OperateType.text:
        return addTextWidget(_operateBtnSize, type, choosen: choosen);
      case OperateType.flip:
        return flipWidget(_operateBtnSize, type, choosen: choosen);
      case OperateType.rotated:
        return rotateWidget(_operateBtnSize, type, choosen: choosen);
      case OperateType.mosaic:
        return mosaicWidget(_operateBtnSize, type, choosen: choosen);
    }
  }

  Widget buildUndoWidget() => undoWidget(_unDoWidgetSize);

  Widget buildBackWidget() => backBtnWidget(_backWidgetSize);

  ///Brush colors
  /// * color's amount in [1,7]
  List<Color> get brushColors;

  ///Text Colors
  /// * color's amount in [1,7]
  List<Color> get textColors;

  ///Slider's theme data
  SliderThemeData get sliderThemeData;

  ///Text config model
  /// * more see [TextEditorPage]
  TextConfigModel get textConfigModel;

  ///Back button on appbar
  Widget backBtnWidget(double limitSize);

  ///Brush widget
  /// * for paint color on canvas.
  Widget brushWidget(double limitSize, OperateType type, {required bool choosen});

  ///Add text widget
  /// * for add some text on canvas.
  Widget addTextWidget(double limitSize, OperateType type, {required bool choosen});

  ///Flip widget
  /// * for flip the canvas.
  Widget flipWidget(double limitSize, OperateType type, {required bool choosen});

  ///Rotate widget
  /// * for rotate the canvas(90 angle each tap).
  Widget rotateWidget(double limitSize, OperateType type, {required bool choosen});

  ///Mosaic widget
  /// * for paint some mosaic on canvas.
  Widget mosaicWidget(double limitSize, OperateType type, {required bool choosen});

  ///Done widget
  /// * for save the edit action and generate a new image as result.
  Widget doneWidget(BoxConstraints constraints);

  ///Undo widget
  /// * for undo last edit action.
  Widget undoWidget(double limitSize);

  ///Reset widget
  /// * for reset rotated action.
  Widget get resetWidget;

  ///Text selected border
  /// * for draw a border the text selected.
  Border get textSelectedBorder;



}















