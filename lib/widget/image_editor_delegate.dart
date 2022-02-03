

import 'package:flutter/material.dart';
import 'package:image_editor_dove/flutter_image_editor.dart';
import 'package:image_editor_dove/widget/float_text_widget.dart';
import 'package:image_editor_dove/widget/text_editor_page.dart';

import 'editor_panel_controller.dart';
import 'slider_widget.dart';


class DefaultTextConfigModel extends TextConfigModel{
  @override
  double get initSize => 14;

  @override
  double get sliderBottomLimit => 14;

  @override
  double get sliderUpLimit => 36;

  @override
  Color get cursorColor => const Color(0xFFF83112);

}

class DefaultImageEditorDelegate extends ImageEditorDelegate{

  Color operatorStatuscolor(bool choosen) => choosen ? Colors.red : Colors.white;

  @override
  List<Color> get brushColors => const <Color>[
    Color(0xFFFA4D32),
    Color(0xFFFF7F1E),
    Color(0xFF2DA24A),
    Color(0xFFF2F2F2),
    Color(0xFF222222),
    Color(0xFF1F8BE5),
    Color(0xFF4E43DB),
  ];

  @override
  List<Color> get textColors => const <Color>[
    Color(0xFFFA4D32),
    Color(0xFFFF7F1E),
    Color(0xFF2DA24A),
    Color(0xFFF2F2F2),
    Color(0xFF222222),
    Color(0xFF1F8BE5),
    Color(0xFF4E43DB),
  ];

  @override
  Widget backBtnWidget(double limitSize) {
    return Icon(Icons.arrow_back_ios_new, size: limitSize);
  }

  @override
  Widget doneWidget(BoxConstraints constraints) {
    return Container(
      constraints: constraints,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent])),
      child: Text(
        'Done',
        style: TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
  }

  @override
  Widget brushWidget(double limitSize, OperateType type, {required bool choosen}) {
    return Icon(Icons.brush_outlined, size: limitSize, color: operatorStatuscolor(choosen));
  }

  @override
  Widget addTextWidget(double limitSize, OperateType type, {required bool choosen}) {
    return Icon(Icons.notes, size: limitSize, color: operatorStatuscolor(choosen));
  }

  @override
  Widget rotateWidget(double limitSize, OperateType type, {required bool choosen}) {
    return Icon(Icons.rotate_right, size: limitSize, color: operatorStatuscolor(choosen));
  }

  @override
  Widget flipWidget(double limitSize, OperateType type, {required bool choosen}) {
    return Icon(Icons.flip, size: limitSize, color: operatorStatuscolor(choosen));
  }

  @override
  Widget mosaicWidget(double limitSize, OperateType type, {required bool choosen}) {
    return Icon(Icons.auto_awesome_mosaic, size: limitSize, color: operatorStatuscolor(choosen));
  }

  @override
  Widget get resetWidget => Text('Reset', style: TextStyle(color: Colors.white, fontSize: 16));

  @override
  SliderThemeData sliderThemeData(BuildContext context) => SliderTheme.of(context).copyWith(
    trackHeight: 2,
    thumbColor: Colors.white,
    disabledThumbColor: Colors.white,
    activeTrackColor: const Color(0xFFF83112),
    inactiveTrackColor: Colors.white.withOpacity(0.5),
    overlayShape: CustomRoundSliderOverlayShape(),
  );

  @override
  TextConfigModel get textConfigModel => DefaultTextConfigModel();

  @override
  Border get textSelectedBorder => DashBorder();

  @override
  Widget undoWidget(double limitSize) => Icon(Icons.undo, size: limitSize, color: Colors.white);

  @override
  Widget get boldTagWidget => Text(
    'Bold',
    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
  );

  @override
  Widget get sliderLeftWidget => _txtFlatWidget('small');

  @override
  Widget get sliderRightWidget => _txtFlatWidget('big');

  Widget _txtFlatWidget(String txt) {
    return Text(
      txt,
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
    );
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

  ///input field's cursor color.
  Color get cursorColor;

  bool get isLegal => initSize >= sliderBottomLimit && initSize <= sliderUpLimit;


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
  SliderThemeData sliderThemeData(BuildContext context);

  ///Slider's tag
  /// * left-flag(small) - Slider - right-flag(big)
  Widget get sliderLeftWidget;

  ///Slider's tag
  /// * left-flag(small) - Slider - right-flag(big)
  Widget get sliderRightWidget;

  ///To control the text style of bold.
  Widget get boldTagWidget;

  ///Text config model
  /// * see also: [TextEditorPage]
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















