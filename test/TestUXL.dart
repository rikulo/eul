//Sample Code: Test UXL

#import("dart:html");
//#import('package:rikulo/app.dart');
//#import('package:rikulo/view.dart');
//#import('package:rikulo_uxl/uxl.dart');
#import('../../rikulo/lib/app.dart');
#import('../../rikulo/lib/view.dart');
#import('../lib/uxl.dart');

class TestUXL extends Activity {

  void onCreate_() {
    mainView.layout.text = "type: linear; orient: vertical";
    test1(mainView);
    test2(mainView);
  }
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
          </attribute>
        </TextView>
      </View>
      ''').create(parent);
  }
  void test2(View parent) {
    new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
      .create(parent);
  }
}

void main() {
  new TestUXL().run();
}
