"""Implementation for `git_binary` rule."""

load(":git_toolchains.bzl", "git_toolchains")

# Heavily inspired by
# https://github.com/bazelbuild/bazel-skylib/blob/7209de9148e98dc20425cf83747613f23d40827b/rules/native_binary.bzl#L23

def _git_binary_impl(ctx):
    out = ctx.actions.declare_file(
        ctx.attr.out if (ctx.attr.out != "") else ctx.attr.name + ".exe",
    )
    git_bin = ctx.toolchains[git_toolchains.type].git_info.git
    ctx.actions.symlink(
        target_file = git_bin,
        output = out,
        is_executable = True,
    )
    return DefaultInfo(
        executable = out,
        files = depset([out]),
    )

git_binary = rule(
    implementation = _git_binary_impl,
    executable = True,
    doc = "Expose the `git` binary.",
    attrs = {
        # "out" is attr.string instead of attr.output, so that it is select()'able.
        "out": attr.string(
            default = "",
            doc = "An output name for the copy of the binary. Defaults to " +
                  "name.exe. (We add .exe to the name by default because it's " +
                  "required on Windows and tolerated on other platforms.)",
        ),
    },
    toolchains = [git_toolchains.type],
)
