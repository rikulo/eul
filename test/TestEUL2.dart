//Sample Code: Test EUL

import 'dart:html';
import 'package:rikulo_ui/view.dart';
import 'package:rikulo_eul/eul.dart';

void main() {
  final View mainView = new View()..addToDocument();
  mainView.layout.text = "type: linear; orient: vertical";

  new EULTemplate.fromNode(document.query("#eul").elements[0]..remove())
                 .create(mainView);
}
