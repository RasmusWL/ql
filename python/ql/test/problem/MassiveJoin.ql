import python
import experimental.dataflow.DataFlow

// import experimental.dataflow.TypeTracker
/** Gets a reference to the `os` module. */
DataFlow::Node os(DataFlow::TypeTracker t) {
  t.start() and
  result = DataFlow::importModule("os")
  or
  exists(DataFlow::TypeTracker t2 | result = os(t2).track(t2, t))
}

/** Gets a reference to the `os` module. */
DataFlow::Node os() { result = os(DataFlow::TypeTracker::end()) }

module os {
  /** Gets a reference to the `os.system` function. */
  DataFlow::Node system(DataFlow::TypeTracker t) {
    t.startInAttr("system") and
    result = os()
    or
    exists(DataFlow::TypeTracker t2 | result = os::system(t2).track(t2, t))
  }

  /** Gets a reference to the `os.system` function. */
  DataFlow::Node system() { result = os::system(DataFlow::TypeTracker::end()) }
}

DataFlow::Node generic_os_attr(DataFlow::TypeTracker t, string name) {
  name = "system" and
  t.startInAttr(name) and
  result = os()
  or
  exists(DataFlow::TypeTracker t2 | result = generic_os_attr(t2, name).track(t2, t))
}

DataFlow::Node generic_os_attr(string name) {
  result = generic_os_attr(DataFlow::TypeTracker::end(), name)
}

DataFlow::Node asger_recommends(DataFlow::TypeTracker t, string name) {
  name = "system" and
  t.start() and
  result.asCfgNode().(AttrNode).getObject(name) = os().asCfgNode()
  or
  exists(DataFlow::TypeTracker t2 | result = asger_recommends(t2, name).track(t2, t))
}

DataFlow::Node asger_recommends(string name) {
  result = asger_recommends(DataFlow::TypeTracker::end(), name)
}

from DataFlow::Node node
where
  // This one works fine
  // node = os::system() and
  //
  // This one leads to massive join
  node = generic_os_attr("system") and
  //
  // This one also leads to massive join
  // node = asger_recommends("system") and
  exists(node.getLocation().getFile().getRelativePath()) and
  exists(CallNode call | call.getFunction() = node.asCfgNode())
select node.getLocation(), node
