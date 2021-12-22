load("@bazel_skylib//lib:paths.bzl", "paths")

# Lovingly inspired by https://www.linuxjournal.com/node/1005818.

def _binary_pkg_impl(ctx):
    #exec_binary = ctx.actions.declare_file("exec_binary.sh")
    #ctx.actions.write(
    #    output = exec_binary,
    #    content = """\
    ##!/usr/bin/env bash
    #{binary}
    #""".format(binary = ctx.executable.binary.path),
    #    is_executable = True,
    #)

    decompress_out = ctx.actions.declare_file(ctx.label.name + "_decompress.sh")
    ctx.actions.expand_template(
        output = decompress_out,
        template = ctx.file._decompress_template,
        substitutions = {
            "{{EXEC_BINARY}}": ctx.executable.binary.path,
        },
        is_executable = True,
    )

    # files_to_compress = [
    #     ctx.executable.binary,
    # ]
    # files_to_compress = depset(
    #     [ctx.executable.binary],
    #     transitive = ctx.attr.binary[DefaultInfo].default_runfiles.files,
    # )
    files_to_compress = ctx.runfiles(
        files = [ctx.executable.binary],
        transitive_files = ctx.attr.binary[DefaultInfo].default_runfiles.files,
    ).files

    compress_dir = ctx.actions.declare_directory(ctx.label.name + "_compress")
    ctx.actions.run_shell(
        outputs = [compress_dir],
        arguments = [compress_dir.path],
        command = """\
mkdir -p "${1}"
""",
    )

    dest_files = []
    for file in files_to_compress.to_list():
        dest_path = paths.join(compress_dir.path, file.short_path)
        dest = ctx.actions.declare_file(dest_path)
        dest_files.append(dest)
        cp_args = ctx.actions.args()
        cp_args.add_all([file, dest])
        ctx.actions.run_shell(
            outputs = [dest],
            inputs = [file],
            arguments = [cp_args],
            command = """\
mkdir -p "$(dirname "${2}")"
cp "${1}" "${2}"
""",
        )

    # DEBUG BEGIN
    print("*** CHUCK files_to_compress.to_list(): ")
    for idx, item in enumerate(files_to_compress.to_list()):
        print("*** CHUCK", idx, ":", item, ", short:", item.short_path, ", path:", item.path)

    # DEBUG END

    archive_out = ctx.actions.declare_file(ctx.label.name + "_archive.tar.gz")
    archive_args = ctx.actions.args()
    archive_args.add(archive_out)
    archive_args.add(compress_dir.path)
    ctx.actions.run_shell(
        outputs = [archive_out],
        inputs = files_to_compress,
        arguments = [archive_args],
        command = """\
    start_dir="${PWD}"
    archive="${start_dir}/${1}"
    compress_dir="${2}"
    cd "${compress_dir}"
    tar -czf ${archive} ./*
    """,
    )

    # TODO: Clean up the command below.

    # archive_out = ctx.actions.declare_file(ctx.label.name + "_archive.tar.gz")
    # archive_args = ctx.actions.args()
    # archive_args.add(archive_out)
    # archive_args.add_all(files_to_compress)
    # ctx.actions.run_shell(
    #     outputs = [archive_out],
    #     inputs = files_to_compress,
    #     arguments = [archive_args],
    #     command = """\
    # # bin_dir="${1}"
    # # shift 1
    # # archive="${1}"
    # # exec_binary="${1}"
    # tar -czf ${@}
    # """,
    # )

    bin_pkg_out = ctx.actions.declare_file(ctx.label.name + ".sh")
    cat_args = ctx.actions.args()
    cat_args.add_all([bin_pkg_out, decompress_out, archive_out])
    ctx.actions.run_shell(
        outputs = [bin_pkg_out],
        inputs = [decompress_out, archive_out],
        arguments = [cat_args],
        command = """\
output="${1}"
shift 1
cat "${@}" > "${output}"
""",
    )

    return [DefaultInfo(executable = bin_pkg_out)]

binary_pkg = rule(
    implementation = _binary_pkg_impl,
    attrs = {
        "binary": attr.label(
            executable = True,
            mandatory = True,
            cfg = "target",
            doc = "The binary to be executed.",
        ),
        "_decompress_template": attr.label(
            # executable = True,
            allow_single_file = True,
            default = "@cgrindel_bazel_starlib//rules/private:decompress.sh.tmpl",
        ),
        # "args": attr.string_list(
        #     doc = "Arguments to be passed to the binary.",
        # ),
        # "file_args": attr.label_keyed_string_dict(
        #     allow_files = True,
        # ),
    },
    doc = "",
)
