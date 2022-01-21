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

  ///text's color
  late ValueNotifier<int> selectedColor;

  Color get _textColor => Color(selectedColor.value);

  ///text's size
  double _size = 14;

  ///text font weight
  FontWeight _fontWeight = FontWeight.normal;

  FloatTextModel buildModel() {
    RenderObject? ro = filedKey.currentContext?.findRenderObject();
    Offset offset = Offset(100, 200);
    if (ro is RenderBox) {
      //adjust text's dy value
      offset = ro.localToGlobal(Offset.zero).translate(0, -(44 + windowStatusBarHeight));
    }
    return FloatTextModel(text: _controller.text, top: offset.dy, left: offset.dx, style: TextStyle(fontSize: _size, color: _textColor));
  }

  void popWithResult() {
    Navigator.pop(context, buildModel());
  }

  void tapBoldBtn() {
    _fontWeight = _fontWeight == FontWeight.bold ? FontWeight.normal : FontWeight.bold;
    setState(() {

    });
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
  void dispose() {
    _node.dispose();
    _controller.dispose();
    super.dispose();
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16),),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 12 , right: 16),
                  child: doneButtonWidget(onPressed: popWithResult),
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: SizedBox()),
                //text area
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
                    style: TextStyle(color: _textColor, fontSize: _size, fontWeight: _fontWeight),
                    decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                //slider
                Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  //color: Colors.white,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: tapBoldBtn,
                        child: Text(
                          'Bold',
                          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      24.hGap,
                      txtFlatWidget('small'),
                      8.hGap,
                      Expanded(child: _buildSlider()),
                      8.hGap,
                      txtFlatWidget('big'),
                      2.hGap,
                    ],
                  ),
                ),
                //color selector
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
