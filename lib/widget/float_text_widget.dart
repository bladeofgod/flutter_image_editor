import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:image_editor_dove/model/float_text_model.dart';

import '../image_editor.dart';



class FloatTextWidget extends StatefulWidget{

  final FloatTextModel textModel;

  const FloatTextWidget({Key? key,
    required this.textModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FloatTextWidgetState();
  }
}

class FloatTextWidgetState extends State<FloatTextWidget> {

  FloatTextModel get model => widget.textModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(mounted) {
        RenderObject? ro = context.findRenderObject();
        if(ro is RenderBox) {
          widget.textModel.size ??= ro.size;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      constraints: BoxConstraints(
        minWidth: 10, maxWidth: 335
      ),
      decoration: BoxDecoration(
        border: model.isSelected ?
            ImageEditor.uiDelegate.textSelectedBorder
            : null
      ),
      child: Text(
        model.text,
        style: model.style,
      ),
    );
  }

}


///Draw dash border.
class DashBorder extends Border{

  DashBorder({
    this.gap = 4.0,
    this.strokeWidth = 2.0,
    this.dashColor = Colors.white,
    BorderSide top = BorderSide.none,
    BorderSide right = BorderSide.none,
    BorderSide bottom = BorderSide.none,
    BorderSide left = BorderSide.none,
  }) : super(top: top, bottom: bottom, left: left, right: right);

  final double gap;

  final double strokeWidth;

  final Color dashColor;

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        TextDirection? textDirection,
        BoxShape shape = BoxShape.rectangle,
        BorderRadius? borderRadius,
      }) {

    Path getDashedPath({
      required math.Point<double> a,
      required math.Point<double> b,
      required gap,
    }) {
      final Size size = Size(b.x - a.x, b.y - a.y);
      final Path path = Path();
      path.moveTo(a.x, a.y);
      bool shouldDraw = true;
      math.Point<double> currentPoint = math.Point<double>(a.x, a.y);

      final num radians = math.atan(size.height / size.width);

      final num dx = math.cos(radians) * gap < 0
          ? math.cos(radians) * gap * -1
          : math.cos(radians) * gap;

      final num dy = math.sin(radians) * gap < 0
          ? math.sin(radians) * gap * -1
          : math.sin(radians) * gap;

      while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
        shouldDraw
            ? path.lineTo(currentPoint.x, currentPoint.y)
            : path.moveTo(currentPoint.x, currentPoint.y);
        shouldDraw = !shouldDraw;
        currentPoint = math.Point(
          currentPoint.x + dx,
          currentPoint.y + dy,
        );
      }
      return path;
    }
    if (isUniform) {
      final Paint dashedPaint = Paint()
        ..color = dashColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      // top line
      final Path _topPath = getDashedPath(
        a: math.Point(rect.topLeft.dx, rect.topLeft.dy),
        b: math.Point(rect.topRight.dx, rect.topRight.dy),
        gap: gap,
      );
      // right line
      final Path _rightPath = getDashedPath(
        a: math.Point(rect.topRight.dx, rect.topRight.dy),
        b: math.Point(rect.bottomRight.dx, rect.bottomRight.dy),
        gap: gap,
      );
      // bottom line
      final Path _bottomPath = getDashedPath(
        a: math.Point(rect.bottomLeft.dx, rect.bottomLeft.dy),
        b: math.Point(rect.bottomRight.dx, rect.bottomRight.dy),
        gap: gap,
      );
      // left line
      final Path _leftPath = getDashedPath(
        a: math.Point(rect.topLeft.dx, rect.topLeft.dy),
        b: math.Point(rect.bottomLeft.dx, rect.bottomLeft.dy),
        gap: gap,
      );

      canvas.drawPath(_topPath, dashedPaint);
      canvas.drawPath(_rightPath, dashedPaint);
      canvas.drawPath(_bottomPath, dashedPaint);
      canvas.drawPath(_leftPath, dashedPaint);
    }

    paintBorder(canvas, rect, top: top, right: right, bottom: bottom, left: left);
  }

}















