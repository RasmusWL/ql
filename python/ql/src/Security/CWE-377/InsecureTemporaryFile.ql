/**
 * @name Insecure temporary file
 * @description Creating a temporary file using this method may be insecure.
 * @kind problem
 * @id py/insecure-temporary-file
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-377
 *       security
 */

import python

FunctionValue temporary_name_function(string mod, string function) {
    (
        mod = "tempfile" and function = "mktemp"
        or
        mod = "os" and
        (
            function = "tmpnam"
            or
            function = "tempnam"
        )
    ) and
    result = Module::named(mod).attr(function)
}

// TODO: I'm not entirely convinced by our example, that this is really good. Need some more investigation and references.

from Call c, string mod, string function
where temporary_name_function(mod, function).getACall().getNode() = c
select c, "Call to deprecated function " + mod + "." + function + " may be insecure."
