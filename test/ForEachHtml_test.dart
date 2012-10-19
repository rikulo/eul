//Sample Code: ScrollView with EL

import 'dart:html';
import 'package:rikulo/view.dart';
import 'package:rikulo_eul/eul.dart';

void main() {
  final View mainView = new View()..addToDocument();
  new EULTemplate.fromNode(document.query("#eul").elements[0]..remove())
                 .create(mainView);
}
