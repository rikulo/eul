//Sample Code: Test UXL

import 'dart:html';
import 'package:rikulo/view.dart';
import 'package:rikulo_uxl/uxl.dart';

void main() {
  final View mainView = new View()..addToDocument();
  mainView.layout.text = "type: linear; orient: vertical";

  new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
                 .create(mainView);
}
