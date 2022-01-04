# Different versions of Bazel (e.g. 4.2.2 vs 5.0-pre) can output the query results
# in a different order. It does not appear to be possible to provide a value for
# `--order_output` to `genquery`. So, we will sort the results using this macro.

def sorted_genquery(name, expression, scope, testonly):
    raw_query_name = name + "_raw"
    native.genquery(
        name = raw_query_name,
        testonly = testonly,
        expression = expression,
        scope = scope,
    )

    native.genrule(
        name = name,
        srcs = [raw_query_name],
        outs = [name],
        testonly = testonly,
        cmd = """\
# cat $(location {src}) | sort > $@
sort -o "$@" "$(location {src})"
""".format(src = raw_query_name),
    )
