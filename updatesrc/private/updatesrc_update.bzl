load(":providers.bzl", "UpdateSrcsInfo")
load(":update_srcs.bzl", "update_srcs")

"""A binary rule that updates the specified source files using the specified \
output files.\
"""

def _updatesrc_update_impl(ctx):
    srcs_len = len(ctx.files.srcs)
    outs_len = len(ctx.files.outs)
    if srcs_len != outs_len:
        fail("""\
The number of srcs does not match the number of outs. \
srcs: {srcs_len}, outs: {outs_len}\
""".format(
            srcs_len = srcs_len,
            outs_len = outs_len,
        ))

    updsrcs = []
    for idx, src in enumerate(ctx.files.srcs):
        out = ctx.files.outs[idx]
        updsrcs.append(update_srcs.create(src = src, out = out))

    update_src_depset = depset(
        updsrcs,
        transitive = [
            dep[UpdateSrcsInfo].update_srcs
            for dep in ctx.attr.deps
        ],
    )
    all_updsrcs = update_src_depset.to_list()

    # Make sure that the output files are included in the runfiles.
    runfiles = ctx.runfiles(files = [updsrc.out for updsrc in all_updsrcs])

    update_sh = ctx.actions.declare_file(
        ctx.label.name + "_update.sh",
    )
    ctx.actions.write(
        output = update_sh,
        content = """
#!/usr/bin/env bash
runfiles_dir=$(pwd)

# When run from a test, build workspace directory is not set. The
# source copy just happens in the sandbox.
if [[ ! -z "${BUILD_WORKSPACE_DIRECTORY}" ]]; then
  cd "${BUILD_WORKSPACE_DIRECTORY}"
fi
""" + "\n".join([
            "cp -f $(readlink \"${{runfiles_dir}}/{out}\") {src}".format(
                src = updsrc.src.short_path,
                out = updsrc.out.short_path,
            )
            for updsrc in all_updsrcs
        ]),
        is_executable = True,
    )

    return DefaultInfo(executable = update_sh, runfiles = runfiles)

updatesrc_update = rule(
    implementation = _updatesrc_update_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = """\
Source files that will be updated by the files listed in the `outs` attribute. \
Every file listed in the `srcs` attribute must have a corresponding output \
file listed in the `outs` attribute.\
""",
            allow_files = True,
        ),
        "outs": attr.label_list(
            doc = """\
Output files that will be used to update the files listed in the `srcs` \
attribute. Every file listed in the `outs` attribute must have a corresponding \
source file list in the `srcs` attribute.\
""",
            allow_files = True,
        ),
        "deps": attr.label_list(
            providers = [[UpdateSrcsInfo]],
            doc = "Build targets that output `UpdateSrcsInfo`.",
        ),
    },
    executable = True,
    doc = """\
Updates the source files in the workspace directory using the specified output \
files.

There are two ways to specify the update mapping for this rule. 

Option #1: You can specify a list of source files and output files using the \
`srcs` and `outs` attributes, respectively. The source file at index 'n' in \
the `srcs` list will be updated by the output file at index 'n' in the `outs` \
list.

Option #2: Rules that provide `UpdateSrcsInfo` can be specified in the `deps` \
attribute.
""",
)
