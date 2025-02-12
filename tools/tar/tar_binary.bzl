"""Implementation for `tar_binary` rule."""

load(":tar_toolchains.bzl", "tar_toolchains")

# Heavily inspired by
# https://tarhub.com/bazelbuild/bazel-skylib/blob/7209de9148e98dc20425cf83747613f23d40827b/rules/native_binary.bzl#L23

def _tar_binary_impl(ctx):
    out = ctx.actions.declare_file(
        ctx.attr.out if (ctx.attr.out != "") else ctx.attr.name + ".exe",
    )
    bsdtar = ctx.toolchains[tar_toolchains.type]
    ctx.actions.symlink(
        target_file = bsdtar.tarinfo.binary,
        output = out,
        is_executable = True,
    )
    return DefaultInfo(
        executable = out,
        files = depset([out]),
    )

tar_binary = rule(
    implementation = _tar_binary_impl,
    executable = True,
    doc = "Expose the `tar` binary.",
    attrs = {
        # "out" is attr.string instead of attr.output, so that it is select()'able.
        "out": attr.string(
            default = "",
            doc = "An output name for the copy of the binary. Defaults to " +
                  "name.exe. (We add .exe to the name by default because it's " +
                  "required on Windows and tolerated on other platforms.)",
        ),
    },
    toolchains = [tar_toolchains.type],
)
