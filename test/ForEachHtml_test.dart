//Sample Code: ScrollView with EL

#import("dart:html");
//#import('package:rikulo/app.dart');
//#import('package:rikulo/view.dart');
//#import('package:rikulo/html.dart');
//#import('package:rikulo_uxl/uxl.dart');
#import('../../rikulo/lib/app.dart');
#import('../../rikulo/lib/view.dart');
#import('../../rikulo/lib/html.dart');
#import('../lib/uxl.dart');

class ForEachHtmlTest extends Activity {
  void onCreate_() {
//    title = "ForEach in html Demo";
//    new UXLTemplate('''
//    <TextView>
//      <attribute name="html">
//        <UL>
//          <li data-forEach="#{['Henri', 'Tom', 'Simon', 'Tim']}"><p>#{each}</p></li>
//        </UL>
//      </attribute>
//    </TextView>
//''').create(mainView);
    new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
    .create(mainView);
  }
}

void main() {
  new ForEachHtmlTest().run();
}
