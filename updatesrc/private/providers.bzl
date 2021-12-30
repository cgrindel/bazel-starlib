UpdateSrcsInfo = provider(
    doc = """\
Information about files that should be copied from the output to the workspace.\
""",
    fields = {
        "update_srcs": """\
A `depset` of structs as created by `update_srcs.create()` which specify the \
source files and their outputs.\
""",
    },
)
