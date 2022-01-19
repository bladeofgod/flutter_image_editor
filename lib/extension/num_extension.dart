

import 'package:flutter/cupertino.dart';

extension EditorNum on num{

  Widget get vGap => SizedBox(height: this.toDouble());

  Widget get hGap => SizedBox(width: this.toDouble());

}












