import python
import semmle.python.security.TaintTracking
import semmle.python.security.strings.Basic
import semmle.python.web.flask.General

/**
 * A flask response, which is vulnerable to any sort of
 * http response malice.
 */
class FlaskRoutedResponse extends HttpResponseTaintSink {
    FlaskRoutedResponse() {
        exists(PyFunctionObject response |
            flask_routing(_, response.getFunction()) and
            this = response.getAReturnedNode()
        )
    }

    override predicate sinks(TaintKind kind) { kind instanceof StringKind }

    override string toString() { result = "flask.routed.response" }
}

class FlaskResponseArgument extends HttpResponseTaintSink {
    FlaskResponseArgument() {
        exists(CallNode call |
            (
                call.getFunction().pointsTo(theFlaskReponseClass())
                or
                call.getFunction().pointsTo(Value::named("flask.make_response"))
            ) and
            call.getArg(0) = this
        )
    }

    override predicate sinks(TaintKind kind) { kind instanceof StringKind }

    override string toString() { result = "flask.response.argument" }
}

// see note in FlaskCookieSet for why we need this TaintKind
class FlaskResponseTaintKind extends TaintKind {
    FlaskResponseTaintKind() { this = "flask.Response" }
}

class FlaskResponseSource extends TaintSource {
    FlaskResponseSource() {
        this.(CallNode).getFunction().pointsTo(theFlaskReponseClass())
        or
        this.(CallNode).getFunction().pointsTo(Value::named("flask.make_response"))
    }

    override predicate isSourceOf(TaintKind kind) {
        kind instanceof FlaskResponseTaintKind
    }
}
