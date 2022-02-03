
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_editor_dove/model/float_text_model.dart';

///The object taht are moving.
enum MoveStuff{
  non,
  text,
}


enum OperateType{
  non,
  brush,//drawing path
  text,//add text to canvas
  flip,//flip image
  rotated,//rotate canvas
  mosaic,//draw mosaic
}

class EditorPanelController {

  static const defaultTrashColor = const Color(0x26ffffff);

  EditorPanelController() {
    colorSelected = ValueNotifier(brushColor.first.value);
  }

  Size? screenSize;

  ///take shot action listener
  /// * it's for hide some non-relative ui.
  /// * e.g. hide status bar, hide bottom bar
  ValueNotifier<bool> takeShot = ValueNotifier(false);

  ValueNotifier<bool> showTrashCan = ValueNotifier(false);

  ///trash background color
  ValueNotifier<Color> trashColor = ValueNotifier(defaultTrashColor);

  ValueNotifier<bool> showAppBar = ValueNotifier(true);

  ValueNotifier<bool> showBottomBar = ValueNotifier(true);

  ValueNotifier<OperateType> operateType = ValueNotifier(OperateType.non);

  ///Is current operate type
  bool isCurrentOperateType(OperateType type) => type.index == operateType.value.index;

  /// is need to show second panel.
  ///  * in some operate type like drawing path, it need a 2nd panel for change color.
  bool show2ndPanel() => operateType.value == OperateType.brush || operateType.value == OperateType.mosaic;

  final List<Color> brushColor = const <Color>[
    Color(0xFFFA4D32),
    Color(0xFFFF7F1E),
    Color(0xFF2DA24A),
    Color(0xFFF2F2F2),
    Color(0xFF222222),
    Color(0xFF1F8BE5),
    Color(0xFF4E43DB),
  ];

  late ValueNotifier<int> colorSelected;

  void selectColor(Color color) {
    colorSelected.value = color.value;
  }

  ///switch operate type
  void switchOperateType(OperateType type) {
    operateType.value = type;
  }


  ///moving object
  /// * non : not moving.
  MoveStuff moveStuff = MoveStuff.non;

  ///trash can position
  Offset trashCanPosition = Offset(111, (20 + window.padding.bottom));

  ///trash can size.
  final Size tcSize = Size(153, 77);

  ///The top and bottom panel's slide duration.
  final Duration panelDuration = const Duration(milliseconds: 300);

  ///hide bottom and top(app) bar.
  void hidePanel() {
    showAppBar.value = false;
    showBottomBar.value = false;
    switchTrashCan(true);
  }

  ///show bottom and top(app) bar.
  void showPanel() {
    showAppBar.value = true;
    showBottomBar.value = true;
    switchTrashCan(false);
  }

  ///hide/show trash can.
  void switchTrashCan(bool show) {
    showTrashCan.value = show;
  }

  ///switch trash can's color.
  void switchTrashCanColor(bool isInside) {
    trashColor.value = isInside ? Colors.red : defaultTrashColor;
  }

  ///move text.
  void moveText(FloatTextModel model) {
    moveStuff = MoveStuff.text;
    movingTarget = model;
  }

  ///release the moving-text.
  void releaseText(DragEndDetails details, FloatTextModel model, Function throwCall) {
    if(isThrowText(pointerUpPosition??Offset.zero, model)) {
      throwCall.call();
    }
    doIdle();
  }

  ///stop moving.
  void doIdle() {
    movingTarget = null;
    pointerUpPosition = null;
    moveStuff = MoveStuff.non;
    switchTrashCanColor(false);
  }

  ///moving object.
  /// * must based on [BaseFloatModel].
  /// * most time it's used to find the [movingTarget] that who just realeased.
  BaseFloatModel? movingTarget;

  ///cache the target taht just released.
  Offset? pointerUpPosition;

  ///pointer moving's callback
  void pointerMoving(PointerMoveEvent event) {
    pointerUpPosition = event.localPosition;
    switch(moveStuff) {
      case MoveStuff.non:
        break;
      case MoveStuff.text:
        if(movingTarget is FloatTextModel) {
          switchTrashCanColor(isThrowText(event.localPosition, movingTarget!));
        }
        break;
    }
  }

  ///decided whether the text is deleted or not.
  bool isThrowText(Offset pointer,BaseFloatModel target) {
    final Rect textR = Rect.fromCenter(center: pointer,
        width: target.floatSize?.width??1,
        height: target.floatSize?.height??1);
    final Rect tcR = Rect.fromLTWH(
        screenSize!.width - trashCanPosition.dx,
        screenSize!.height - trashCanPosition.dy - tcSize.height,
        tcSize.width,
        tcSize.height);
    return textR.overlaps(tcR);
  }

}




















