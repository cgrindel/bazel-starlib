def _hash_sha256_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name)
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
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The file whose contents should be hashed.",
        ),
        "_hash_tool": attr.label(
            executable = True,
            cfg = "host",
            default = "@cgrindel_bazel_starlib//tools:generate_sha256",
        ),
    },
    doc = """\
Generates a SHA256 hash for the specified file and writes it to a file with the \
same name as the label.\
""",
)
