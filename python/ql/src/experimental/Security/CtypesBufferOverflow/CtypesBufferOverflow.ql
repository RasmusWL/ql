/**
 * @name Buffer overflow due to `repr` implementation error on `ctypes`
 * @description See https://bugs.python.org/issue42938 and CVE-2021-3177
 * @kind path-problem
 * @tags security
 *       CVE-2021-3177
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs
import DataFlow::PathGraph

/**
 * A taint-tracking configuration for detecting command injection vulnerabilities.
 */
class CtypesBufferOverflowConfiguration extends TaintTracking::Configuration {
  CtypesBufferOverflowConfiguration() { this = "CtypesBufferOverflowConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) {
    sink =
      API::moduleImport("ctypes")
          .getMember(["c_double", "c_float"])
          .getMember("from_param")
          .getACall()
          .(DataFlow::CallCfgNode)
          .getArg(0)
  }

  override predicate isAdditionalTaintStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(DataFlow::CallCfgNode call | call = node2 |
      call.getFunction().asExpr().(Name).getId() = "float" and
      call.getArg(0) = node1
    )
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof StringConstCompare
  }
}

from CtypesBufferOverflowConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink,
  "This ctypes construction depends on $@, " +
    "and can therefore lead to Buffer Overflow (and possibly Remote Code Execution).",
  source.getNode(), "a user-provided value"
