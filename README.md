#Rikulo EUL

[Rikulo EUL](http://rikulo.org) (Embeddable User-interface Language) is a markup language allowing developers to define user-interface in HTML 5 and XML.

Unlike [Rikulo UXL](https://github.com/rikulo/rikulo-uxl), which compiles the markup language to Dart, EUL is interpreted at run time and can be embedded in Dart code (as a string) or HTML pages (as a HTML fragment).

* [Home](http://rikulo.org)
* [Documentation](http://docs.rikulo.org)
* [API Reference](http://api.rikulo.org/rikulo-eul/latest/)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/rikulo-eul/issues)

Rikulo EUL is distributed under the Apache 2.0 License.

##Install from Dart Pub Repository

Add this to your `pubspec.yaml` (or create it):

    dependencies:
      rikulo_eul:

Then run the [Pub Package Manager](http://pub.dartlang.org/doc) (comes with the Dart SDK):

    pub install

##Install from Github for Bleeding Edge Stuff

To install stuff that is still in development, add this to your `pubspec.yam`:

    dependencies:
      rikulo_eul:
        git: git://github.com/rikulo/rikulo-eul.git

For more information, please refer to [Pub: Dependencies](http://pub.dartlang.org/doc/pubspec.html#dependencies).

##Usage

Example 1: Everything starts from the EULTemplate:

(TextEUL.dart)

    import 'dart:html';
    import 'package:rikulo/view.dart';
    import 'package:rikulo_eul/eul.dart'; //(required) EUL classes and utilities
    import 'package:rikulo_eul/impl.dart'; //(optional) EUL implementation

    void main() {
      final View mainView = new View()..addToDocument()
      mainView.layout.text = "type: linear; orient: vertical";

      //Define the template with a string
      new EULTemplate('''
        <View layout="type: linear">
          <View layout="type: linear; orient: vertical">
            <CheckBox forEach="#{['Apple', 'Orange', 'Banana', 'Pomelo']}" text="#{each}"></CheckBox>
          </View>
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

(TextEUL.html)

    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <link rel="stylesheet" type="text/css" href="../packages/rikulo/resource/css/view.css" />
      </head>
      <body>
        <style>
        .list {
          border: 2px solid #886;
          border-radius: 6px;
        }
        </style>
        <script type="application/dart" src="TestEUL2.dart"></script>
        <script src="../packages/rikulo/resource/js/dart.js"></script>
      </body>
    </html>

Example2: Or you can choose to read the template definition from the html page.

(TextEUL2.dart)

    import 'dart:html';
    import 'package:rikulo/view.dart';
    import 'package:rikulo_eul/eul.dart'; //(required) EUL classes and utilities
    import 'package:rikulo_eul/impl.dart'; //(optional) EUL implementation

    void main() {
      final View mainView = new View()..addToDocument()
      mainView.layout.text = "type: linear; orient: vertical";

      //Define the template from the element node "eul"
      new EULTemplate.fromNode(document.query("#eul").elements[0]..remove())
          .create(mainView);
    }

(TextEUL2.html)

    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <link rel="stylesheet" type="text/css" href="../packages/rikulo/resource/css/view.css" />
      </head>
      <body>
        <style>
        .list {
          border: 2px solid #886;
          border-radius: 6px;
        }
        </style>
        <div id="eul" style="display: none">
          <View layout="type: linear">
            <View layout="type: linear; orient: vertical">
              <CheckBox forEach="#{['Apple', 'Orange', 'Banana', 'Pomelo']}" text="#{each}"></CheckBox>
            </View>
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
        </div>
        <script type="application/dart" src="TestEUL2.dart"></script>
        <script src="../packages/rikulo/resource/js/dart.js"></script>
      </body>
    </html>

##Pros and Cons

> Rikulo UXL depends on mirrors heavily. For better performance and smaller footprint, it is suggested to use [Rikulo UXL](https://github.com/rikulo/rikulo-uxl) instead if applicable.

###Pros

* The user interface can be defined easily in a similar manner to HTML pages.
* MVC/MVP and data-binding for improving the separation of view, model and controller.
* The content can be indexed by search engines if you embed it as HTML fragment.
* Ready for MVVM design pattern.

###Cons

* It is interpreted at run time based on mirrors, so the performance is slower and the tree shaking of `dart2js` might not work as effective as expressing UI in Dart or in [UXL](https://github.com/rikulo/rikulo-uxl).

##Notes to Contributors

###Create Addons

Rikulo is easy to extend. The simplest way to enhance Rikulo is to [create a new repository](https://help.github.com/articles/create-a-repo) and add your own great widgets and libraries to it.

###Fork Rikulo EUL

If you'd like to contribute back to the core, you can [fork this repository](https://help.github.com/articles/fork-a-repo) and send us a pull request, when it is ready.

Please be aware that one of Rikulo's design goals is to keep the sphere of API as neat and consistency as possible. Strong enhancement always demands greater consensus.

If you are new to Git or GitHub, please read [this guide](https://help.github.com/) first.
