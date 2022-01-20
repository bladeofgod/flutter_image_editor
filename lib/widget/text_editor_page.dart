import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_editor/model/float_text_model.dart';

import '../image_editor.dart';
import 'package:image_editor/extension/num_extension.dart';

import 'slider_widget.dart';


///A page for input some text to canvas.
class TextEditorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TextEditorPageState();
  }
}

class TextEditorPageState extends State<TextEditorPage> with LittleWidgetBinding, WindowUiBinding{
  final FocusNode _node = FocusNode();

  final GlobalKey filedKey = GlobalKey();

  final TextEditingController _controller = TextEditingController();

  final List<Color> textColorList = const <Color>[
    Color(0xFFFA4D32),
    Color(0xFFFF7F1E),
    Color(0xFF2DA24A),
    Color(0xFFF2F2F2),
    Color(0xFF222222),
    Color(0xFF1F8BE5),
    Color(0xFF4E43DB),
  ];

  ///字体颜色
  late ValueNotifier<int> selectedColor;

  Color get _textColor => Color(selectedColor.value);

  ///字体大小
  double _size = 14;

  FloatTextModel buildModel() {
    RenderObject? ro = filedKey.currentContext?.findRenderObject();
    Offset offset = Offset(100, 200);
    if (ro is RenderBox) {
      //需要修正一下dy的值
      offset = ro.localToGlobal(Offset.zero).translate(0, -(44 + windowStatusBarHeight));
    }
    return FloatTextModel(text: _controller.text, top: offset.dy, left: offset.dx, style: TextStyle(fontSize: _size, color: _textColor));
  }

  void pop() {
    if (_controller.text.isEmpty) {
      Navigator.pop(context);
    } else {
      popWithResult();
    }
  }

  void popWithResult() {
    Navigator.pop(context, buildModel());
  }

  @override
  void initState() {
    super.initState();
    selectedColor = ValueNotifier(textColorList.first.value);
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) _node.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          ClipRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity, height: double.infinity,
                color: Colors.black38,),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 44,
                  padding: EdgeInsets.only(left: 16, top: 12),
                  child: Text('取消', style: TextStyle(color: Colors.white, fontSize: 16),),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 6 , right: 16),
                  child: doneButtonWidget(onPressed: pop),
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: SizedBox()),
                //文字区域
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    key: filedKey,
                    maxLines: 50,
                    minLines: 1,
                    controller: _controller,
                    focusNode: _node,
                    cursorColor: const Color(0xFFF83112),
                    style: TextStyle(color: _textColor, fontSize: _size),
                    decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                //滑块
                Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  //color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        '文字',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      24.hGap,
                      txtFlatWidget('小'),
                      8.hGap,
                      Expanded(child: _buildSlider()),
                      8.hGap,
                      txtFlatWidget('大'),
                      2.hGap,
                    ],
                  ),
                ),
                //颜色
                Container(
                  height: 41,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  //color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: textColorList
                        .map<Widget>((e) => CircleColorWidget(
                      color: e,
                      valueListenable: selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          selectedColor.value = color.value;
                        });
                      },
                    ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          thumbColor: Colors.white,
          disabledThumbColor: Colors.white,
          activeTrackColor: const Color(0xFFF83112),
          inactiveTrackColor: Colors.white.withOpacity(0.5),
          overlayShape: CustomRoundSliderOverlayShape(),
        ),
        child: Slider(
          value: _size,
          max: 36,
          min: 14,
          onChanged: (v) {
            _size = v;
            setState(() {});
          },
        ));
  }

  Widget txtFlatWidget(String txt) {
    return Text(
      txt,
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
    );
  }

}
