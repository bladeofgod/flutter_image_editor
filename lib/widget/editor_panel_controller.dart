
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_editor/model/float_text_model.dart';


enum MoveStuff{
  non,
  text,//移动文字
}

///操作类型
enum OperateType{
  non,
  brush,//涂鸦
  text,//添加文字
  flip,//翻转
  rotated,//旋转
  mosaic,//马赛克
}

class EditorPanelController {

  EditorPanelController({required this.screenSize}) {
    colorSelected = ValueNotifier(brushColor.first.value);
  }

  final Size screenSize;

  ///截图时为true (一次性)
  /// * 用于隐藏非截图内容 如 底部控制bar
  /// * 完成截图后，editor页面将会退出
  ValueNotifier<bool> takeShot = ValueNotifier(false);

  ValueNotifier<bool> showTrashCan = ValueNotifier(false);

  ///未激活垃圾桶背景
  static const defaultTrashColor = const Color(0x26ffffff);

  ValueNotifier<Color> trashColor = ValueNotifier(defaultTrashColor);

  ValueNotifier<bool> showAppBar = ValueNotifier(true);

  ValueNotifier<bool> showBottomBar = ValueNotifier(true);

  ValueNotifier<OperateType> operateType = ValueNotifier(OperateType.non);

  ///是否是当前操作类型
  bool isCurrentOperateType(OperateType type) => type.index == operateType.value.index;

  ///是否显示副面板
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

  ///切换操作类型
  void switchOperateType(OperateType type) {
    operateType.value = type;
  }

  ///根据操作类型获取对应资源路径
  String getOperateTypeRes(OperateType type) {
    final bool isCurrent = isCurrentOperateType(type);
    switch(type) {
      case OperateType.non:
        return '';
      case OperateType.brush:
        return isCurrent ? R.libAssetsIcEditGraffitiSelected : R.libAssetsIcEditGraffitiUnselected;
      case OperateType.text:
        return isCurrent ? R.libAssetsIcEditFontSelected : R.libAssetsIcEditFontUnselected;
      case OperateType.flip:
        return isCurrent ? R.libAssetsIcEditFlipSelected : R.libAssetsIcEditFlipUnselected;
      case OperateType.rotated:
        return isCurrent ? R.libAssetsIcEditRotateSelected : R.libAssetsIcEditRotateUnselected;
      case OperateType.mosaic:
        return isCurrent ? R.libAssetsIcEditMosaicSelected : R.libAssetsIcEditMosaicUnselected;
    }
  }

  ///拖动的对象
  /// * 无、 文字
  MoveStuff moveStuff = MoveStuff.non;

  ///垃圾桶位置
  Offset trashCanPosition = Offset(111, (20 + window.padding.bottom));

  ///垃圾桶尺寸
  final Size tcSize = Size(153, 77);

  ///标记垃圾桶位置
  //set markTrashCanPosition(Offset offset) => trashCanPosition = offset;

  ///顶部和底部面板的滑动时间
  final Duration panelDuration = const Duration(milliseconds: 300);

  ///隐藏控制和app bar
  void hidePanel() {
    showAppBar.value = false;
    showBottomBar.value = false;
    switchTrashCan(true);
  }

  ///显示控制和app bar
  void showPanel() {
    showAppBar.value = true;
    showBottomBar.value = true;
    switchTrashCan(false);
  }

  ///显/隐 垃圾桶
  void switchTrashCan(bool show) {
    showTrashCan.value = show;
  }

  ///切换垃圾桶颜色
  void switchTrashCanColor(bool isInside) {
    trashColor.value = isInside ? Colors.red : defaultTrashColor;
  }

  ///移动文字
  void moveText(FloatTextModel model) {
    moveStuff = MoveStuff.text;
    movingTarget = model;
  }

  ///释放移动文字
  void releaseText(DragEndDetails details, FloatTextModel model, Function throwCall) {
    if(isThrowText(pointerUpPosition??Offset.zero, model)) {
      throwCall.call();
    }
    doIdle();
  }

  ///停止移动
  void doIdle() {
    movingTarget = null;
    pointerUpPosition = null;
    moveStuff = MoveStuff.non;
    switchTrashCanColor(false);
  }

  ///移动的目标
  BaseFloatModel? movingTarget;

  ///缓存移动完成后的最后一个触摸点
  /// * 由于控制拆分，所以此处需要缓存一个。
  Offset? pointerUpPosition;

  ///指针移动中
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

  ///是否丢弃text widget
  bool isThrowText(Offset pointer,BaseFloatModel target) {
    final Rect textR = Rect.fromCenter(center: pointer,
        width: target.floatSize?.width??1,
        height: target.floatSize?.height??1);
    final Rect tcR = Rect.fromLTWH(
        screenSize.width - trashCanPosition.dx,
        screenSize.height - trashCanPosition.dy - tcSize.height,
        tcSize.width,
        tcSize.height);
    return textR.overlaps(tcR);
  }

}




















