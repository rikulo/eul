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
   *     <div data-as="View" data-layout="type: linear">
   *       UXL: <div data-as="Switch" data-value="true"></div>
   *     </div>
   *
   * Dart:
   *
   *     new Tempalte.fromNode(document.query("#templ").elements[0]..remove());
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
      final attrs = elem.attributes;
      final _UXLELContextImpl ectx = new _UXLELContextImpl(ctx);
      //1) handle forEach, if and unless
      final Iterable forEach = loopForEach ? null: _getForEach(ectx, attrs, elem);
      if (forEach != null) {
        final prev = ctx.getVariable("each");
        final prevStatus = ctx.getVariable("forEachStatus");
        final _ForEachStatus status = new _ForEachStatus(prevStatus);
        if (forEach is Collection)
          status.length = forEach.length;
        ctx.setVariable("forEachStatus", status);
        int j = 0;
        for (final each in forEach) {
          ctx.setVariable("each", each);
          status.index = j++;
          status.each = each;
          _create(ctx, parent, before, node, created, true);
        }
        ctx.setVariable("forEachStatus", prevStatus);
        ctx.setVariable("each", prev);
        return;
      } else if (!_isEffective(ectx, attrs, elem)) {
        return; //ignored
      }

      //2) handle special elements
      String name = elem.tagName.toLowerCase();
      String s = _getAttr(attrs, "as");
      if (s != null) name = s;
      else if (name == "div")
        name = "View"; //default
      switch (name) {
      case "attribute":
        uiFactory.setProperty(parent,
          _getAttr(attrs, "name", name), _evalInner(ectx, elem));
        return; //done
      case "import":
        for (final n in _getAttr(attrs, "name", name).split(','))
          ctx.mirrors.import(n.trim());
        return;
      case "variable":
        ctx.setVariable(_getAttr(attrs, "name", name), _evalInner(ectx, elem));
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
      view = uiFactory.newInstance(ctx.mirrors, parent, before, name);

      //4) instantiate controller
      Controller ctrl;
      if ((s = _getAttr(attrs, "apply")) != null) {
        final k = s.indexOf(':');
        final cls = (k >= 0 ? s.substring(k + 1): s).trim();
        if (cls.startsWith("#{")) {
          ctrl = ELUtil.eval(ectx, cls);
        } else {
          ClassMirror mirror = ctx.mirrors.getControllerMirror(cls);
          if (mirror == null)
            throw new UIException("Cannot find the specified controller class [$cls]");
          ctrl = ClassUtil.newInstanceByClassMirror(mirror);
        }
        if (k > 0)
          ctx.setVariable(s.substring(0, k).trim(), ctrl);
      }

      //5) assign properties
      for (String key in attrs.getKeys()) {
        if (_isSpecialAttr(key))
          continue; //ignore (since they have been processed)

        Object value = attrs[key];

        if (key.startsWith("data-"))
          key = key.substring(5);

        if (_isStringAttr(key)) {
          value = _resolveValue(ectx, value, ClassUtil.STRING_MIRROR);
        } else {
          MethodMirror setter = ClassUtil.getSetter(reflect(view).type, key);
          if (setter == null)
            throw new UIException("Cannot find proper setter [$key] for $view");
          value = _resolveValue(ectx, value, ClassUtil.getCorrespondingClassMirror(setter.parameters[0].type));
        }

        uiFactory.setProperty(view, key, value);
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
  Iterable _getForEach(_UXLELContextImpl ectx, Map<String, String> attrs, Element elm) {
    String val = _getAttr(attrs, 'forEach');
    if (val == null)
      return null;
    var result = ELUtil.eval(ectx, val);
    if (result != null && result is! Iterable)
      throw new UIException("Expect an Iterable for [forEach] attribute of $elm");
    return result;
  }
  bool _isEffective(_UXLELContextImpl ectx, Map<String, String> attrs, Element elm) {
    bool if0 = true;
    String val = _getAttr(attrs, "if");
    if (val != null)
      if0 = ELUtil.eval(ectx, val, ClassUtil.BOOL_MIRROR);

    bool unless0 = false;
    val = _getAttr(attrs, "unless");
    if (val != null)
      unless0 = ELUtil.eval(ectx, val, ClassUtil.BOOL_MIRROR);
    return if0 && !unless0;
  }

  /** Evaluate the inner content of the given element.
   */
  _evalInner(_UXLELContextImpl ectx, Element elem) {
    switch (elem.nodes.length) {
      case 0: return "";
      case 1:
        if (elem.nodes[0] is Text) {
          //evaluate wholeText before return
          return ELUtil.eval(ectx, (elem.nodes[0] as Text).wholeText);
        }
        break;
    }

    final StringBuffer sb = new StringBuffer();
    _xmlInner(ectx._ctx, sb, elem);
    return sb.toString();
  }
  void _xmlInner(_Context ctx, StringBuffer sb, Element elem) {
    for (Node n in elem.nodes){
      if (n is Element) {
        final e = n as Element;
        if (_xmlBeg(ctx, sb, e)) {
          _xmlInner(ctx, sb, e);
          _xmlEnd(sb, e);
        }
      } else if (n is Text) {
        sb.add((n as Text).wholeText);
      } else if (n is ProcessingInstruction) {
        final pi = n as ProcessingInstruction;
        sb.add('<?').add(pi.target).add(' ').add(pi.data).add('?>');
      } else if (n is Comment) {
        sb.add('<!--').add((n as Comment).data).add('-->');
      }//ignore unrecogized nodes (such as Entity, Notation...)
    }
  }
  bool _xmlBeg(_Context ctx, StringBuffer sb, Element elem, [bool loopForEach=false]) {
    final attrs = elem.attributes;
    final _UXLELContextImpl ectx = new _UXLELContextImpl(ctx);
    //1) handle forEach, if and unless
    final Iterable forEach = loopForEach ? null: _getForEach(ectx, attrs, elem);
    if (forEach != null) {
      final prev = ctx.getVariable("each");
      final prevStatus = ctx.getVariable("forEachStatus");
      final _ForEachStatus status = new _ForEachStatus(prevStatus);
      if (forEach is Collection)
        status.length = forEach.length;
      ctx.setVariable("forEachStatus", status);
      int j = 0;
      for (final each in forEach) {
        ctx.setVariable("each", each);
        status.index = j++;
        status.each = each;
        _xmlBeg(ctx, sb, elem, true);
        _xmlInner(ctx, sb, elem);
        _xmlEnd(sb, elem);
      }
      ctx.setVariable("forEachStatus", prevStatus);
      ctx.setVariable("each", prev);
      return false;
    } else if (!_isEffective(ectx, attrs, elem)) {
      return false; //ignored
    }

    //2) handle special elements
    String tagName = elem.tagName;
    String s = _getAttr(attrs, "as");
    if (s != null) tagName = s;
    switch (tagName.toLowerCase()) {
      case "attribute":
      case "import":
      case "template":
        throw new UIException("$tagName not allowed in <attribute> and <variable>");
      case "variable":
        ctx.setVariable(_getAttr(attrs, "name", tagName), _evalInner(ectx, elem));
        return false;
    }
    sb.add('<').add(tagName);

    for (String key in attrs.getKeys())
      sb.add(' ').add(key).add('="').add(attrs[key]).add('"');

    sb.add('>');
    return true;
  }
  static void _xmlEnd(StringBuffer sb, Element elem) {
    sb.add('</').add(elem.tagName).add('>');
  }
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
  new Set.from(["as", "forEach", "if", "unless", "apply",
    "data-as", "data-forEach", "data-if", "data-unless", "data-apply"]);
bool _isStringAttr(String name) => _strAttrs.contains(name);
final Set<String> _strAttrs =
  new Set.from(["class", "style", "layout", "profile",
                "data-class", "data-style", "data-layout", "data-profile"]);
_resolveValue(_UXLELContextImpl ectx, String expr, TypeMirror expectedType)
  => ELUtil.eval(ectx, expr, expectedType);

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

/**
 * The ELContext for UXL
 */
class _UXLELContextImpl extends elimpl.ELContextImpl {
  final _Context _ctx;
  _UXLELContextImpl(_Context ctx)
      : this._ctx = ctx,
        super(new CompositeELResolver()
          ..add(new UXLVarELResolver(ctx))
          ..add(new ClassELResolver())
          ..add(new LibELResolver())
          ..add(elimpl.ELContextImpl.getDefaultResolver()));
}

/**
 * ELResolver for UXL context variables
 */
class UXLVarELResolver implements ELResolver {
  final _Context _ctx;

  UXLVarELResolver(this._ctx);

  //@Override
  Object getValue(ELContext context, Object base, Object property) {
    if (context == null)
      throw const NullPointerException();

    if (base != null || property == null)
      return null;

    //try variable resolving in the _Context
    Object value = _ctx.resolver(property);

    //try class in the imported libraries
    if (value == null)
      value = _ctx.mirrors.getClassMirror(property);

    //try library in the imported libaries
    if (value == null)
      value = _ctx.mirrors.getLibraryMirror(property);

    context.setPropertyResolved(value != null);

    return value;
  }

  //@Override
  ClassMirror getType(ELContext context, Object base, Object property) {
    Object val = getValue(context, base, property);
    return val == null ? null : reflect(val).type;
  }

  //@Override
  void setValue(ELContext context, Object base, Object property, Object value) {
    throw new PropertyNotWritableException(message(context,
          "resolverNotWriteable", [property]));
  }

  //@Override
  bool isReadOnly(ELContext context, Object base, Object property)
    => true;

  //@Override
  ClassMirror getCommonPropertyType(ELContext context, Object base)
    => ClassUtil.OBJECT_MIRROR;

  //@Override
  Object invoke(ELContext context, Object base, Object method,
                List params, [Map<String, Object> namedArgs])
    => null;
}

/**
 * Represents the runtime information of each iteration caused by
 * 'forEach' in UXL
 */
class _ForEachStatus {
  /** Returns the status of the outter forEach */
  final _ForEachStatus previous;

  /** Returns the object of the current round of the iteration */
  var each;

  /** Returns the index of the current round of the iteration */
  int index;

  /** Returns the length of the iteration */
  int length;

  _ForEachStatus(this.previous);
}
