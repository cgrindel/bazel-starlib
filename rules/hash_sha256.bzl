def _hash_sha256_impl(ctx):
    # out = ctx.actions.declare_file(ctx.label.name + ".sha256")
    out = ctx.actions.declare_file(ctx.file.src.basename + ".sha256")
    ctx.actions.run_shell(
        outputs = [out],
        inputs = [ctx.file.src],
        command = """
sha256sum {src} | sed -E -n 's/^([^[:space:]]+).*/\1/gp' > {out}
""".format(
            src = ctx.file.src.path,
            out = out.path,
        ),
    )
    return DefaultInfo(files = depset([out]))

hash_sha256 = rule(
    implementation = _hash_sha256_impl,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The file whose contents should be hashed.",
        ),
    },
    doc = "Generates a SHA256 hash for the specified file.",
)
