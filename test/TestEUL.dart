//Sample Code: Test EUL

import 'dart:html';
import 'package:rikulo_ui/view.dart';
import 'package:rikulo_eul/eul.dart';

void main() {
  final View mainView = new View()..addToDocument();
  mainView.layout.text = "type: linear; orient: vertical";
  new EULTemplate('''
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
    ''').create(mainView);
}
