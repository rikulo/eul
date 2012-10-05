//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Sep 06, 2012  6:31:33 PM
// Author: tomyeh

/**
 * The UI factory used to instantiate instances of [View], and
 * assigning the properties.
 */
abstract class UIFactory {
  factory UIFactory() => new DefaultUIFactory();

  /** Instantiate an instance of the given name.
   * It also adds the view as a child of the given parent, if not null.
   *
   * Notice that the name is case-insensitive.
   */
  View newInstance(Mirrors mirrors, View parent, View before, String name);
  /** Instantiate a text.
   */
  View newText(View parent, View before, String text);
  /** Assigns the given value to the property with the given name.
   */
  void setProperty(View view, String name, Object value);
}

/** The default implementation that is based on mirror.
 */
class DefaultUIFactory implements UIFactory {
  View newInstance(Mirrors mirrors, View parent, View before, String name) {
    ClassMirror cm = mirrors.getViewMirror(name.toLowerCase());
    if (cm == null)
      throw new UIException("Cannot find the specified View class [$name]");
    View view = ClassUtil.newInstanceByClassMirror(cm);
    if (view != null && parent != null)
      parent.addChild(view, before);
    return view;
  }

  View newText(View parent, View before, String text) {
    View view = new TextView(text);
    if (parent != null)
      parent.addChild(view, before);
    return view;
  }

  void setProperty(View view, String name, Object value) {
    switch (name) {
      case "class":
        view.classes.add(value);
        break;
      case "style":
        view.style.cssText = value;
        break;
      case "layout":
        view.layout.text = value;
        break;
      case "profile":
        view.profile.text = value;
        break;
      default:
        _setProperty0(view, name, value);
    }
  }

  void _setProperty0(View view, String name, Object value) {
    MethodMirror setter = ClassUtil.getSetter(reflect(view).type, name);
    if (setter == null)
      throw new UIException("Cannot find proper setter [$name] for $view");
    ClassUtil.invoke(view, setter, [value]);
  }
}

/** The UI factory.
 *
 * You can assign your own implementation if you'd like.
 */
UIFactory uiFactory = new UIFactory();
