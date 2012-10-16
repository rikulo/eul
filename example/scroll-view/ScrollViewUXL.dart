//Sample Code: ScrollView with EL

import 'dart:html';
import 'package:rikulo/view.dart';
import 'package:rikulo_uxl/uxl.dart';

List pseudoArray(int size) => new List(size);

void main() {
  final View mainView = new View()..addToDocument();
  new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
                 .create(mainView);
}
