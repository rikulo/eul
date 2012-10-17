#Rikulo UXL

[Rikulo UXL](http://rikulo.org) (User-interface eXtensible Language) is a markup language that allows developers to define feature-rich user-interface in HTML 5 and XML.

* [Home](http://rikulo.org)
* [Documentation](http://docs.rikulo.org)
* [API Reference](http://api.rikulo.org/rikulo-uxl/latest/)
* [Discussion](http://stackoverflow.com/questions/tagged/rikulo)
* [Issues](https://github.com/rikulo/rikulo-uxl/issues)

Rikulo UXL is distributed under the Apache 2.0 License.

##Installation

Add this to your `pubspec.yaml` (or create it):

    dependencies:
      rikulo_uxl:

Then run the [Pub Package Manager](http://pub.dartlang.org/doc) (comes with the Dart SDK):

    pub install

##Usage

Example 1: Everything starts from the UXLTemplate:

(TextUXL.dart)

    import 'dart:html';
    import 'package:rikulo/view.dart';
    import 'package:rikulo_uxl/uxl.dart'; //(required) UXL classes and utilities
    import 'package:rikulo_uxl/impl.dart'; //(optional) UXL implementation

    void main() {
      final View mainView = new View()..addToDocument()
      mainView.layout.text = "type: linear; orient: vertical";

      //Define the template with a string
      new UXLTemplate('''
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

(TextUXL.html)

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
        <script type="application/dart" src="TestUXL2.dart"></script>
        <script src="../packages/rikulo/resource/js/dart.js"></script>
      </body>
    </html>

Example2: Or you can choose to read the template definition from the html page.

(TextUXL2.dart)

    import 'dart:html';
    import 'package:rikulo/view.dart';
    import 'package:rikulo_uxl/uxl.dart'; //(required) UXL classes and utilities
    import 'package:rikulo_uxl/impl.dart'; //(optional) UXL implementation

    void main() {
      final View mainView = new View()..addToDocument()
      mainView.layout.text = "type: linear; orient: vertical";

      //Define the template from the element node "uxl"
      new UXLTemplate.fromNode(document.query("#uxl").elements[0]..remove())
          .create(mainView);
    }

(TextUXL2.html)

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
        <div id="uxl" style="display: none">
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
        <script type="application/dart" src="TestUXL2.dart"></script>
        <script src="../packages/rikulo/resource/js/dart.js"></script>
      </body>
    </html>

##Advantages

* The user interface can be defined easily in a similar manner to HTML pages.
* The content can be indexed by search engines.
* Supporting MVC/MVP for improving the separation of view, model and controller.
* Ready for MVVM design pattern.

##Notes to Contributors

###Create Addons

Rikulo is easy to extend. The simplest way to enhance Rikulo is to [create a new repository](https://help.github.com/articles/create-a-repo) and add your own great widgets and libraries to it.

###Fork Rikulo

If you'd like to contribute back to the core, you can [fork this repository](https://help.github.com/articles/fork-a-repo) and send us a pull request, when it is ready.

Please be aware that one of Rikulo's design goals is to keep the sphere of API as neat and consistency as possible. Strong enhancement always demands greater consensus.

If you are new to Git or GitHub, please read [this guide](https://help.github.com/) first.
