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

class ScrollViewUXLTest extends Activity {

  void onCreate_() {
    title = "ScrollView Demo";
    new UXLTemplate.fromNode(document.query("#uxl").elements[0].remove())
    .create(mainView);
  }
}

List pseudoArray(int size) => new List(size);

void main() {
  new ScrollViewUXLTest().run();
}
