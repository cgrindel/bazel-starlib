"""Definition for hash_sha256 rule."""

def _hash_sha256_impl(ctx):
    out_filename = ctx.attr.out if ctx.attr.out != "" else ctx.label.name
    out = ctx.actions.declare_file(out_filename)
    args = ctx.actions.args()
    args.add("--source", ctx.file.src)
    args.add("--output", out)
    ctx.actions.run(
        outputs = [out],
        inputs = [ctx.file.src],
        executable = ctx.executable._hash_tool,
        arguments = [args],
        # The tool needs to be able to look for a utility to generate the SHA256
        use_default_shell_env = True,
    )
    return DefaultInfo(
        files = depset([out]),
        # To ensure that passing the outputs of this rule to a sh_binary or
        # sh_test data attribute works, we need to put the output in the
        # runfiles.
        # Bazel issue: https://github.com/bazelbuild/bazel/issues/4519
        runfiles = ctx.runfiles(files = [out]),
    )

hash_sha256 = rule(
    implementation = _hash_sha256_impl,
    attrs = {
        "out": attr.string(
            doc = "The filename for the output file.",
        ),
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The file whose contents should be hashed.",
        ),
        "_hash_tool": attr.label(
            executable = True,
            cfg = "exec",
            default = "@cgrindel_bazel_starlib//bzlrelease/tools:generate_sha256",
        ),
    },
    doc = """\
Generates a SHA256 hash for the specified file and writes it to a file. 

If an output filename is provided, the value is written to a file with that \
name. Otherwise, it is written to a file with the name of the declaration.
""",
)
