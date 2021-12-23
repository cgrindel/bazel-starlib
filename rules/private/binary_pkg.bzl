load("@bazel_skylib//lib:paths.bzl", "paths")

# Lovingly inspired by https://www.linuxjournal.com/node/1005818.

def _copy_to_compress_dir(ctx, compress_dir_name, file):
    if file.path.startswith("external/"):
        dest_path = paths.join(compress_dir_name, ctx.workspace_name, file.path)
    else:
        dest_path = paths.join(compress_dir_name, ctx.workspace_name, file.short_path)
    dest = ctx.actions.declare_file(dest_path)

    cp_args = ctx.actions.args()
    cp_args.add_all([file, dest])
    ctx.actions.run_shell(
        outputs = [dest],
        inputs = [file],
        arguments = [cp_args],
        command = """\
src="${1}"
dest="${2}"
mkdir -p "$(dirname "${src}")"
cp "${src}" "${dest}"
""",
    )
    return dest

def _binary_pkg_impl(ctx):
    dest_files = []
    compress_dir_name = ctx.label.name + "_compress"

    #exec_binary = ctx.actions.declare_file("exec_binary.sh")
    #ctx.actions.write(
    #    output = exec_binary,
    #    content = """\
    ##!/usr/bin/env bash
    #{binary}
    #""".format(binary = ctx.executable.binary.path),
    #    is_executable = True,
    #)

    # Make sure that something exists in the compress dir
    placeholder_out = ctx.actions.declare_file(
        paths.join(compress_dir_name, "placeholder"),
    )
    dest_files.append(placeholder_out)
    ctx.actions.write(
        output = placeholder_out,
        content = "# Intentionally blank",
    )
    compress_dir_path = paths.dirname(placeholder_out.path)

    # Copy the binary to the compress dir
    binary_dest = _copy_to_compress_dir(ctx, compress_dir_name, ctx.executable.binary)
    dest_files.append(binary_dest)
    compress_dir_prefix_len = len(compress_dir_path) + 1
    binary_path = binary_dest.path[compress_dir_prefix_len:]

    # Copy the runfiles for the binary.
    for file in ctx.attr.binary[DefaultInfo].default_runfiles.files.to_list():
        dest = _copy_to_compress_dir(ctx, compress_dir_name, file)
        dest_files.append(dest)

    # Create an archive file with the binary and the runfiles
    archive_out = ctx.actions.declare_file(ctx.label.name + "_archive.tar.gz")
    archive_args = ctx.actions.args()
    archive_args.add(archive_out)
    archive_args.add(compress_dir_path)
    ctx.actions.run_shell(
        outputs = [archive_out],
        inputs = dest_files,
        arguments = [archive_args],
        command = """\
archive="${1}"
src_dir="${2}"
compress_dir="$(basename "${src_dir}")_clean"
mkdir -p "${compress_dir}"
cp -R -L "${src_dir}"/* "${compress_dir}"
tar -czf ${archive} -C "${compress_dir}" . 
""",
    )

    # Create the decompression script
    decompress_out = ctx.actions.declare_file(ctx.label.name + "_decompress.sh")
    ctx.actions.expand_template(
        output = decompress_out,
        template = ctx.file._decompress_template,
        substitutions = {
            "{{EXEC_BINARY}}": binary_path,
        },
        is_executable = True,
    )

    # Construct the final output by concatenating the decompression script with the archive.
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
