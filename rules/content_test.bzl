def _do_equals(ctx):
    actual_file = ctx.file.file
    expected_file = ctx.actions.declare_file(ctx.label.name + "_expected")
    ctx.actions.write(
        output = expected_file,
        content = ctx.attr.equals,
    )
    files = depset(direct = [expected_file])
    test_exe = ctx.actions.declare_file(ctx.label.name + "_equals.sh")
    ctx.actions.expand_template(
        template = ctx.file._equals_template,
        output = test_exe,
        substitutions = {
            "%EXPECTED%": expected_file.short_path,
            "%ACTUAL%": actual_file.short_path,
        },
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [actual_file, expected_file])
    return (test_exe, runfiles, files)

def _content_test_impl(ctx):
    test_exe = None
    runfiles = None
    files = None
    if ctx.attr.equals != "":
        test_exe, runfiles, files = _do_equals(ctx)

    if test_exe == None:
        fail("No content evaluation criteria were specified.")

    return [DefaultInfo(files = files, executable = test_exe, runfiles = runfiles)]

content_test = rule(
    implementation = _content_test_impl,
    attrs = {
        "file": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The file whose contents will be evaluated.",
        ),
        "equals": attr.string(
            doc = """\
The contents of the file must equal the value of this attribute.\
""",
        ),
        "_equals_template": attr.label(
            allow_single_file = True,
            default = ":content_test_equals.sh.template",
        ),
    },
    test = True,
    doc = "Evaluates whether the file contents meet the specified criteria.",
)
