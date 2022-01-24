import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'extension/num_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'model/float_text_model.dart';
import 'widget/drawing_board.dart';
import 'widget/editor_panel_controller.dart';
import 'widget/float_text_widget.dart';
import 'widget/text_editor_page.dart';


///The editor's result.
class EditorImageResult {
  ///image width
  final int imgWidth;

  ///image height
  final int imgHeight;

  ///new file after edit
  final File newFile;

  EditorImageResult(this.imgWidth, this.imgHeight, this.newFile);
}

class ImageEditor extends StatefulWidget {
  ///origin image
  /// * input for edit
  final File originImage;

  ///edited-file's save path.
  /// * if null will save in temporary file.
  final Directory? savePath;

  const ImageEditor({Key? key, required this.originImage, this.savePath}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImageEditorState();
  }
}

class ImageEditorState extends State<ImageEditor>
    with SignatureBinding, ScreenShotBinding, TextCanvasBinding, RotateCanvasBinding, LittleWidgetBinding, WindowUiBinding {
  final EditorPanelController _panelController = EditorPanelController();

  double get headerHeight => windowStatusBarHeight;

  double get bottomBarHeight => 121 + windowBottomBarHeight;

  ///Edit arear height.
  double get canvasHeight => screenHeight - bottomBarHeight - headerHeight;

  ///Operation panel button's horizontal space.
  Widget get controlBtnSpacing => 5.hGap;

  ///Save the edited-image to [widget.savePath] or [getTemporaryDirectory()].
  void saveImage() {
    _panelController.takeShot.value = true;
    screenshotController.capture(pixelRatio: 1.0).then((value) async {
      final paths = widget.savePath ?? await getTemporaryDirectory();
      final file = await File('${paths.path}/' + DateTime.now().toString() + '.jpg').create();
      file.writeAsBytes(value ?? []);
      decodeImg().then((value) {
        if (value == null) {
          Navigator.pop(context);
        } else {
          Navigator.pop(context, EditorImageResult(value.width, value.height, file));
        }
      }).catchError((e) {
        Navigator.pop(context);
      });
    });
  }

  Future<ui.Image?> decodeImg() async {
    return await decodeImageFromList(widget.originImage.readAsBytesSync());
  }

  static ImageEditorState? of(BuildContext context) {
    return context.findAncestorStateOfType<ImageEditorState>();
  }

  @override
  void initState() {
    super.initState();
    initPainter();
  }

  @override
  Widget build(BuildContext context) {
    _panelController.screenSize ??= windowSize;
    return Material(
      color: Colors.black,
      child: Listener(
        onPointerMove: (v) {
          _panelController.pointerMoving(v);
        },
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              //appBar
              ValueListenableBuilder<bool>(
                  valueListenable: _panelController.showAppBar,
                  builder: (ctx, value, child) {
                    return AnimatedPositioned(
                        top: value ? 0 : -headerHeight,
                        left: 0, right: 0,
                        child: ValueListenableBuilder<bool>(
                            valueListenable: _panelController.takeShot,
                            builder: (ctx, value, child) {
                              return Opacity(
                                opacity: value ? 0 : 1,
                                child: AppBar(
                                  iconTheme: IconThemeData(color: Colors.white, size: 16),
                                  leading: backWidget(),
                                  backgroundColor: Colors.transparent,
                                  actions: [
                                    resetWidget(onTap: resetCanvasPlate)
                                  ],
                                ),
                              );
                            }),
                        duration: _panelController.panelDuration);
                  }),
              //canvas
              Positioned.fromRect(
                  rect: Rect.fromLTWH(0, headerHeight, screenWidth, canvasHeight),
                  child: RotatedBox(
                    quarterTurns: rotateValue,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildImage(),
                        _buildBrushCanvas(),
                        //buildTextCanvas(),
                      ],
                    ),
                  )),
              //bottom operation(control) bar
              ValueListenableBuilder<bool>(
                  valueListenable: _panelController.showBottomBar,
                  builder: (ctx, value, child) {
                    return AnimatedPositioned(
                        bottom: value ? 0 : -bottomBarHeight,
                        child: SizedBox(
                          width: screenWidth,
                          child: ValueListenableBuilder<bool>(
                              valueListenable: _panelController.takeShot,
                              builder: (ctx, value, child) {
                                return Opacity(
                                  opacity: value ? 0 : 1,
                                  child: _buildControlBar(),
                                );
                              }),
                        ),
                        duration: _panelController.panelDuration);
                  }),
              //trash bin
              ValueListenableBuilder<bool>(
                  valueListenable: _panelController.showTrashCan,
                  builder: (ctx, value, child) {
                    return AnimatedPositioned(
                        bottom: value ? _panelController.trashCanPosition.dy : -headerHeight,
                        left: _panelController.trashCanPosition.dx,
                        child: _buildTrashCan(),
                        duration: _panelController.panelDuration);
                  }),
              //text canvas
              Positioned.fromRect(
                  rect: Rect.fromLTWH(0, headerHeight, screenWidth, screenHeight),
                  child: RotatedBox(
                    quarterTurns: rotateValue,
                    child: buildTextCanvas(),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.black,
      width: screenWidth,
      height: bottomBarHeight,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: bottomBarHeight / 2,
            child: ValueListenableBuilder<OperateType>(
              valueListenable: _panelController.operateType,
              builder: (ctx, value, child) {
                return Opacity(
                  opacity: _panelController.show2ndPanel() ? 1 : 0,
                  child: Row(
                    children: [
                      if(value == OperateType.brush)
                        ..._panelController.brushColor
                            .map<Widget>((e) => CircleColorWidget(
                          color: e,
                          valueListenable: _panelController.colorSelected,
                          onColorSelected: (color) {
                            changePainterColor(color);
                          },
                        ))
                            .toList(),
                      Expanded(child: SizedBox()),
                      unDoWidget(onPressed: undo)
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: bottomBarHeight / 2,
            child: Row(
              children: [
                _buildButton(OperateType.brush, 'Draw', onPressed: () {
                  switchPainterMode(DrawStyle.normal);
                }),
                controlBtnSpacing,
                _buildButton(OperateType.text, 'Text', onPressed: toTextEditorPage),
                controlBtnSpacing,
                _buildButton(OperateType.flip, 'Flip', onPressed: flipCanvas),
                controlBtnSpacing,
                _buildButton(OperateType.rotated, 'Rotate', onPressed: rotateCanvasPlate),
                controlBtnSpacing,
                _buildButton(OperateType.mosaic, 'Mosaic', onPressed: () {
                  switchPainterMode(DrawStyle.mosaic);
                }),
                Expanded(child: SizedBox()),
                doneButtonWidget(onPressed: saveImage),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(flipValue),
      child: Container(
        alignment: Alignment.center,
        child: Image.file(widget.originImage),
      ),
    );
  }

  Widget _buildTrashCan() {
    return ValueListenableBuilder<Color>(
        valueListenable: _panelController.trashColor,
        builder: (ctx, value, child) {
          final bool isActive = value.value == EditorPanelController.defaultTrashColor.value;
          return Container(
            width: _panelController.tcSize.width,
            height: _panelController.tcSize.height,
            decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Column(
              children: [
                12.vGap,
                Icon(Icons.delete_outline, size: 32, color: Colors.white,),
                4.vGap,
                Text(isActive ? 'move here for delete' : 'release to delete',
                  style: TextStyle(color: Colors.white, fontSize: 12),)
              ],
            ),
          );
        });
  }

  Widget _buildButton(OperateType type, String txt, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: () {
        _panelController.switchOperateType(type);
        onPressed?.call();
      },
      child: ValueListenableBuilder(
        valueListenable: _panelController.operateType,
        builder: (ctx, value, child) {
          return SizedBox(
            width: 44,
            height: 41,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getOperateTypeRes(type, choosen: _panelController.isCurrentOperateType(type)),
                Text(
                  txt,
                  style: TextStyle(
                      color: _panelController.isCurrentOperateType(type)
                          ? const Color(0xFFFA4D32) : const Color(0xFF999999), fontSize: 11),
                )
              ],
            ),
          );
        },
      ),
    );
  }


}

mixin LittleWidgetBinding<T extends StatefulWidget> on State<T> {
  
  ///go back widget
  Widget backWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () {
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back_ios_new, size: 22,),
    );
  }

  ///operation button in control bar
  Widget getOperateTypeRes(OperateType type, {required bool choosen}) {
    final Color color = choosen ? Colors.red : Colors.white;
    switch(type) {
      case OperateType.non:
        return SizedBox();
      case OperateType.brush:
        return Icon(Icons.brush_outlined, size: 24, color: color,);
      case OperateType.text:
        return Icon(Icons.notes, size: 24, color: color,);
      case OperateType.flip:
        return Icon(Icons.flip, size: 24, color: color,);
      case OperateType.rotated:
        return Icon(Icons.rotate_right, size: 24, color: color,);
      case OperateType.mosaic:
        return Icon(Icons.auto_awesome_mosaic, size: 24, color: color,);
    }
  }
  
  ///action done widget
  Widget doneButtonWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 54,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            gradient: const LinearGradient(colors: [Colors.green, Colors.greenAccent])),
        child: Text(
          'Done',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  ///undo action
  Widget unDoWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(Icons.undo, size: 20, color: Colors.white,),
    );
  }

  ///Ignore pointer evenet by [OperateType]
  Widget ignoreWidgetByType(OperateType type, Widget child) {
    return ValueListenableBuilder(
        valueListenable: realState?._panelController.operateType ?? ValueNotifier(OperateType.non),
        builder: (ctx, type, c) {
          return IgnorePointer(
            ignoring: type != OperateType.brush && type != OperateType.mosaic,
            child: child,
          );
        });
  }

  ///reset button
  Widget resetWidget({VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6 , right: 16),
      child: ValueListenableBuilder<OperateType>(
        valueListenable: realState?._panelController.operateType ?? ValueNotifier(OperateType.non),
        builder: (ctx, value, child) {
          return Offstage(
            offstage: value != OperateType.rotated,
            child: GestureDetector(
              onTap: onTap,
              child: Text('Reset', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),);
        },
      ),
    );
  }

}

///This binding can make editor to roatate canvas
/// * for now, the paint-path,will change his relative position of canvas
/// * when canvas rotated. because the paint-path area it's full canvas and
/// * origin image is not maybe. if force to keep the relative path, will reduce
/// * the paint-path area.
mixin RotateCanvasBinding<T extends StatefulWidget> on State<T> {

  ///canvas rotate value
  /// * 90 angle each time.
  int rotateValue = 0;

  ///canvas flip value
  /// * 180 angle each time.
  double flipValue = 0;

  ///flip canvas
  void flipCanvas() {
    flipValue = flipValue == 0 ? math.pi : 0;
    setState(() {});
  }

  ///routate canvas
  /// * will effect image, text, drawing board
  void rotateCanvasPlate() {
    rotateValue++;
    setState(() {});
  }

  ///reset canvas
  void resetCanvasPlate() {
    rotateValue = 0;
    setState(() {

    });
  }

}

///text painting
mixin TextCanvasBinding<T extends StatefulWidget> on State<T> {
  late StateSetter textSetter;

  final List<FloatTextModel> textModels = [];

  void addText(FloatTextModel model) {
    textModels.add(model);
    refreshTextCanvas();
  }

  ///delete a text from canvas
  void deleteTextWidget(FloatTextModel target) {
    textModels.remove(target);
    refreshTextCanvas();
  }

  void toTextEditorPage() {
    realState?._panelController.hidePanel();
    Navigator.of(context)
        .push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return TextEditorPage();
        }))
        .then((value) {
      realState?._panelController.showPanel();
      if (value is FloatTextModel) {
        addText(value);
      }
    });
  }

  void refreshTextCanvas() {
    textSetter.call(() {});
  }

  Widget buildTextCanvas() {
    return StatefulBuilder(builder: (tCtx, setter) {
      textSetter = setter;
      return Stack(
        alignment: Alignment.center,
        children: textModels
            .map<Widget>((e) => Positioned(
          child: _wrapWithGesture(
              FloatTextWidget(
                textModel: e,
              ),
              e),
          left: e.left,
          top: e.top,
        ))
            .toList(),
      );
    });
  }

  Widget _wrapWithGesture(Widget child, FloatTextModel model) {
    void pointerDetach(DragEndDetails? details) {
      if (details != null) {
        //touch event up
        realState?._panelController.releaseText(details, model, () {
          deleteTextWidget(model);
        });
      } else {
        //touch event cancel
        realState?._panelController.doIdle();
      }
      model.isSelected = false;
      refreshTextCanvas();
      realState?._panelController.showPanel();
    }

    return GestureDetector(
      child: child,
      onPanStart: (_) {
        realState?._panelController.moveText(model);
      },
      onPanUpdate: (details) {
        model.isSelected = true;
        model.left += details.delta.dx;
        model.top += details.delta.dy;
        refreshTextCanvas();
        realState?._panelController.hidePanel();
      },
      onPanEnd: (d) {
        pointerDetach(d);
      },
      onPanCancel: () {
        pointerDetach(null);
      },
    );
  }
}

///drawing board
mixin SignatureBinding<T extends StatefulWidget> on State<T> {
  final List<Widget> pathRecord = [];

  late StateSetter canvasSetter;

  ///painter stroke width.
  double pStrockWidth = 5;

  ///painter color
  Color pColor = Colors.redAccent;

  ///painter controller
  late SignatureController painterController;

  @override
  void initState() {
    super.initState();
    pColor = Color(realState?._panelController.colorSelected.value ?? Colors.yellow.value);
  }

  ///switch painter's style
  /// * e.g. color、mosaic
  void switchPainterMode(DrawStyle style) {
    changePainterColor(pColor);
    painterController.drawStyle = style;
  }

  ///change painter's color
  void changePainterColor(Color color) async {
    pColor = color;
    realState?._panelController.selectColor(color);
    pathRecord.insert(
        0,
        RepaintBoundary(
          child: CustomPaint(
              painter: SignaturePainter(painterController),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: double.infinity, maxWidth: double.infinity, maxHeight: double.infinity),
              )),
        ));
    //savePath();
    initPainter();
    _refreshBrushCanvas();
  }

  void _refreshBrushCanvas() {
    pathRecord.removeLast();
    //add new layer.
    pathRecord.add(Signature(
      controller: painterController,
      backgroundColor: Colors.transparent,
    ));
    _refreshCanvas();
  }

  ///undo last drawing.
  void undo() {
    painterController.undo();
  }

  ///refresh canvas.
  void _refreshCanvas() {
    canvasSetter(() {});
  }

  void initPainter() {
    painterController = SignatureController(penStrokeWidth: pStrockWidth, penColor: pColor);
  }

  Widget _buildBrushCanvas() {
    if (pathRecord.isEmpty) {
      pathRecord.add(Signature(
        controller: painterController,
        backgroundColor: Colors.transparent,
      ));
    }
    return StatefulBuilder(builder: (ctx, canvasSetter) {
      this.canvasSetter = canvasSetter;
      return realState?.ignoreWidgetByType(OperateType.brush, Stack(
        children: pathRecord,
      )) ?? SizedBox();
    });
  }

  @override
  void dispose() {
    pathRecord.clear();
    super.dispose();
  }
}

mixin ScreenShotBinding<T extends StatefulWidget> on State<T> {
  final ScreenshotController screenshotController = ScreenshotController();
}

///information about window
mixin WindowUiBinding<T extends StatefulWidget> on State<T> {

  Size get windowSize => MediaQuery.of(context).size;

  double get windowStatusBarHeight => ui.window.padding.top;

  double get windowBottomBarHeight => ui.window.padding.bottom;

  double get screenWidth => windowSize.width;

  double get screenHeight => windowSize.height;

}

extension _BaseImageEditorState on State {
  ImageEditorState? get realState {
    if (this is ImageEditorState) {
      return this as ImageEditorState;
    }
    return null;
  }
}

typedef OnColorSelected = void Function(Color color);

class CircleColorWidget extends StatefulWidget {
  final Color color;

  final ValueNotifier<int> valueListenable;

  final OnColorSelected onColorSelected;

  const CircleColorWidget({Key? key, required this.color, required this.valueListenable, required this.onColorSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CircleColorWidgetState();
  }
}

class CircleColorWidgetState extends State<CircleColorWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onColorSelected(widget.color);
      },
      child: ValueListenableBuilder<int>(
        valueListenable: widget.valueListenable,
        builder: (ctx, value, child) {
          final double size = value == widget.color.value ? 25 : 21;
          return Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: value == widget.color.value ? 4 : 2),
              shape: BoxShape.circle,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }


}
