//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Sep 06, 2012  3:34:34 PM
// Author: tomyeh

/**
 * The template representing a UXL document.
 */
class UXLTemplate implements Template {
  final List<Node> _nodes;

  /** Instantiate a template from a string, which must be a valid XML document.
   *
   * Examples:
   * 
   *     new UXLTemplate('''
   *        <View layout="type: linear">
   *          UXL: <Switch value="true">
   *        </View>
   *        ''');
   */
  factory UXLTemplate(String xml)
  => new UXLTemplate.fromNode(
      new DOMParser().parseFromString(xml, "text/xml").documentElement);
  /** Instantiated from a fragment of a DOM tree.
   *
   * Examples:
   * 
   * HTML:
   *
   *     <div data-view="View" data-layout="type: linear">
   *       UXL: <div data-view="Switch" data-value="true"></div>
   *     </div>
   *
   * Java:
   *
   *     new Tempalte.fromNode(document.query("#templ").elements[0].remove());
   *
   * Notice that it is OK to use the XML format as described in [UXLTemplate] constructor,
   * though it is not a valid HTML document.
   */
  UXLTemplate.fromNode(Node node): _nodes = [node];
  UXLTemplate.fromNodes(List<Node> nodes): _nodes = nodes;

  /** Creates and returns the views based this template.
   *
   * + [parent] the parent. If null, the created view(s) won't have parent; nor attached.
   * + [before] the child of the parent that new views will be inserted before.
   * Ignored if null.
   */
  List<View> create([View parent, View before, Resolver resolver]) {
    final List<View> created = [];
    final ctx = new _Context(new Mirrors(), resolver);
    for (Node node in _nodes)
      _create(ctx, parent, before, node, created);
    return created;
  }
  void _create(_Context ctx, View parent, View before, Node node,
    [List<View> created, bool loopForEach=false]) {
    View view;
    if (node is Element) {
      final Element elem = node as Element;

      //1) handle forEach, if and unless
      final Iterable forEach = loopForEach ? null: _getForEach(elem);
      if (forEach != null) {
        final prev = ctx.getVariable("each");
        for (final each in forEach) {
          ctx.setVariable("each", each);
          _create(ctx, parent, before, node, created, true);
        }
        ctx.setVariable("each", prev);
        return;
      } else if (!_isEffective(elem)) {
        return; //ignored
      }

      //2) handle special elements
      final attrs = elem.attributes;
      String name = elem.tagName.toLowerCase();
      switch (name) {
      case "attribute":
        uiFactory.setProperty(parent,
          _getAttr(attrs, "name", name), XMLUtil.getInner(elem));
        return; //done
      case "import":
        for (final n in _getAttr(attrs, "name", name).split(','))
          ctx.mirrors.import(n.trim());
        return;
      case "variable":
        //TODO: handle expression
        ctx.setVariable(_getAttr(attrs, "name", name), XMLUtil.getInner(elem));
        return;
      case "template":
        view.templates[_getAttr(attrs, "name", name)] = new UXLTemplate.fromNode(node);
        return; //done
      case "pseudo":
        for (Node n in node.nodes)
          _create(ctx, parent, null, n, created);
        return; //done
      }

      //3) create a view (including pseudo)
      String s = _getAttr(attrs, "view");
      if (s != null)
        name = s;
      else if (name == "div")
        name = "View"; //default
      view = uiFactory.newInstance(ctx.mirrors, parent, before, name);

      //4) instantiate controller
      Controller ctrl;
      if ((s = _getAttr(attrs, "apply")) != null) {
        final k = s.indexOf(':');
        final cls = (k >= 0 ? s.substring(k + 1): s).trim();
        if (cls.startsWith("#{")) {
          //TODO: handle expression
        } else {
          ClassMirror mirror = ctx.mirrors.getControllerMirror(cls);
          //TODO: instantiate and assign a variable if necessary
        }
        if (k > 0)
          ctx.setVariable(s.substring(0, k).trim(), ctrl);
      }

      //5) assign properties
      for (String key in attrs.getKeys()) {
        if (_isSpecialAttr(key))
          continue; //ignore (since they have been processed)

        uiFactory.setProperty(view,
          key.startsWith("data-") ? key.substring(5): key, attrs[key]);
      }

      //6) handle the child nodes
      for (Node n in node.nodes)
        _create(ctx, view, null, n);

      //7) invoke controller at the end
      if (ctrl != null)
        ctrl.apply(view);
    } else if (node is Text) {
      final text = (node as Text).wholeText.trim();
      if (!text.isEmpty())
        view = uiFactory.newText(parent, before, text);
    }

    if (created != null && view != null)
      created.add(view);
  }
  Iterable _getForEach(Element elem) => null; //TODO
  bool _isEffective(Element elem) => true; //TODO
}

/**
 * [requiredBy] -- if specified, it the element that requires this attribute.
 */
String _getAttr(Map<String, String> attrs, String name, [String requiredBy]) {
  String val = attrs[name];
  if (val == null)
    val = attrs["data-$name"];
  if (val == null && requiredBy != null)
    throw new UIException("<$requiredBy> requires the $name attribute");
  return val;
}
bool _isSpecialAttr(String name) => _spcAttrs.contains(name);
final Set<String> _spcAttrs =
  new Set.from(["view", "forEach", "if", "unless", "apply",
    "data-view", "data-forEach", "data-if", "data-unless", "data-apply"]);

/** The context used to create views from a UXL document.
 */
class _Context {
  final Mirrors mirrors;
  final Resolver _userResolver;
  final Map<String, Dynamic> _vars;
  Resolver _resolver;

  _Context(this.mirrors, this._userResolver): _vars = {} {
    _resolver = (String name) {
      final val = _vars[name];
      return val != null || _vars.containsKey(name) ? val:
        _userResolver != null ? _userResolver(name): null;
    };
  }

  void setVariable(String name, var value) {
    _vars[name] = value;
  }
  getVariable(String name) => _vars[name];
  Resolver get resolver => _resolver;
}
