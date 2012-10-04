//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Sat, Sep 08, 2012 12:31:38 AM
// Author: tomyeh

/**
 * The mirrors used in a UXL document.
 */
interface Mirrors default _Mirrors {
  Mirrors();

  void import(String name);
  /** Returns the class mirror of the view ([View]) with given name.
   *
   * Notice that it is class insensitive.
   */
  ClassMirror getViewMirror(String name);
  /** Returns the class mirror of the controller ([Controller]) with given name.
   */
  ClassMirror getControllerMirror(String name);
  /** Returns the class mirror of the specified class name in the mirrors */
  ClassMirror getClassMirror(String className);
  /** Returns the library mirror of the specified prefix name in the mirrors */
  LibraryMirror getLibraryMirror(String prefix);
}

class _Mirrors implements Mirrors {
  final List<_MirrorsOfLib> _libs;
  final Set<String> _names;

  _Mirrors() : _libs = [], _names = new Set() {
    import("rikulo:view");
  }

  void import(String name) {
    final String pattern = " as ";
    final List<String> names = name.split(pattern);
    final String name0 = names[0].trim();
    final String prefix = names.length > 1 ? names[1].trim() : null;
    if (!_names.contains(name0)) {
      _names.add(name0);
      _libs.add(_import(name0, prefix));
    }
  }
  ClassMirror getViewMirror(String name) {
    for (_MirrorsOfLib lib in _libs) {
      final mirror = lib.getViewMirror(name);
      if (mirror != null)
        return mirror;
    }
    return null;
  }
  ClassMirror getControllerMirror(String name) {
    for (_MirrorsOfLib lib in _libs) {
      final mirror = lib.getControllerMirror(name);
      if (mirror != null)
        return mirror;
    }
    return null;
  }
  ClassMirror getClassMirror(String className) {
    for (_MirrorsOfLib lib in _libs) {
      final mirror = lib.getClassMirror(className);
      if (mirror != null)
        return mirror;
    }
    return null;
  }
  LibraryMirror getLibraryMirror(String prefix) {
    for (_MirrorsOfLib lib in _libs) {
      if (prefix == lib._prefix)
        return lib._libMirror;
    }
    return null;
  }
}

/** Mirrors in a single library.
 */
class _MirrorsOfLib {
  final LibraryMirror _libMirror;
  final String _prefix;
  final Map<String, ClassMirror> _views, _ctrls;

  _MirrorsOfLib(this._libMirror, this._prefix) : _views = {}, _ctrls = {};

  //note: it is case-insensitive
  ClassMirror getViewMirror(String name) => _views[name.toLowerCase()];
  ClassMirror getControllerMirror(String name) => _ctrls[name];

  //it is case-sensitive
  ClassMirror getClassMirror(String className) => _libMirror.classes[className];
}

ClassMirror VIEW_MIRROR = ClassUtil.forName('rikulo:view.View');
ClassMirror CONTROLLER_MIRROR = ClassUtil.forName('rikulo_uxl.Controller');
_MirrorsOfLib _import(String name, String prefix) {
  if (_libs == null)
    _libs = {};

  _MirrorsOfLib lib = _libs[name];
  if (lib == null) {
    //load from mirrors
    LibraryMirror lm = currentMirrorSystem().libraries[name];
    if (lm == null)
      throw new UIException("Cannot find the specified library [$name]");
    _libs[name] = lib = new _MirrorsOfLib(lm, prefix);

    lm.classes.forEach((String k, ClassMirror v) {
      if (ClassUtil.isAssignableFrom(VIEW_MIRROR, v))
        lib._views[k.toLowerCase()] = v;
      else if (ClassUtil.isAssignableFrom(CONTROLLER_MIRROR, v))
        lib._ctrls[k.toLowerCase()] = v;
    });
  }
  return lib;
}
Map<String, _MirrorsOfLib> _libs;
