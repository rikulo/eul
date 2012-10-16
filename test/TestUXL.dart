//Sample Code: Test UXL

import 'dart:html';
import 'package:rikulo/view.dart';
import 'package:rikulo_uxl/uxl.dart';

void test1(View parent) {
  new UXLTemplate('''
    <View layout="type: linear">
      <CheckBox text="Apple"/>
      <CheckBox text="Orange"/>
      <TextView class="list">
        <attribute name="html">
          <ul>
            <li>This is the first item of TextView with HTML</li>
            <li style="font-weight: bold">This is the second</li>
          </ul>
          <ol>
          <li forEach="#{['Henri', 'Tom', 'Simon', 'Tim']}">#{each}</li>
          </ol>
        </attribute>
      </TextView>
    </View>
    ''').create(parent);
}
void test2(View parent) {
  new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
    .create(parent);
}

void main() {
  final View mainView = new View()..addToDocument();
  mainView.layout.text = "type: linear; orient: vertical";
  test1(mainView);
  test2(mainView);
}
