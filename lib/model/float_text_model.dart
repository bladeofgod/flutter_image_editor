import 'package:flutter/cupertino.dart';

///Text widget model, for help to move text-widget.
class FloatTextModel extends BaseFloatModel{

  String text;

  TextStyle? style;

  ///the top of position
  double top;
  ///the left of position
  double left;
  ///widget's size
  Size? size;

  bool isSelected;

  FloatTextModel({
    required this.text,
    this.style,
    required this.top,
    required this.left,
    this.isSelected = false,
  });

  @override
  Size? get floatSize => size;
}

abstract class BaseFloatModel{
  Size? get floatSize;
}















