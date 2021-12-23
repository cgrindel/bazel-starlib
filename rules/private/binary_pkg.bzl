load("@bazel_skylib//lib:paths.bzl", "paths")

# Lovingly inspired by https://www.linuxjournal.com/node/1005818.

_EXTERNAL_PREFIX = "external/"
_EXTERNAL_PREFIX_LEN = len(_EXTERNAL_PREFIX)

def _copy_to_compress_dir(ctx, compress_dir_name, file):
    # Depending upon the type of file, we may copy it to multiple locations
    dest_paths = []
    if file.path.startswith(_EXTERNAL_PREFIX):
        dest_paths.extend([
            # Copy to the <workspace_name>/external/<external_name>
            paths.join(compress_dir_name, ctx.workspace_name, file.path),
            # Copy to the <external_name>
            # This is needed to mimic runfiles.bash expectations.
            paths.join(compress_dir_name, file.path[_EXTERNAL_PREFIX_LEN:]),
        ])
    else:
        dest_paths.append(
            paths.join(compress_dir_name, ctx.workspace_name, file.short_path),
        )

    # Declare destination files
    destinations = [
        ctx.actions.declare_file(path)
        for path in dest_paths
    ]

    for dest in destinations:
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

    return destinations

def _binary_pkg_impl(ctx):
    dest_files = []
    compress_dir_name = ctx.label.name + "_compress"

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
    binary_dests = _copy_to_compress_dir(ctx, compress_dir_name, ctx.executable.binary)
    binary_dest = binary_dests[0]
    dest_files.append(binary_dest)
    compress_dir_prefix_len = len(compress_dir_path) + 1
    binary_path = binary_dest.path[compress_dir_prefix_len:]

    # Copy the runfiles for the binary.
    for file in ctx.attr.binary[DefaultInfo].default_runfiles.files.to_list():
        dests = _copy_to_compress_dir(ctx, compress_dir_name, file)
        dest_files.extend(dests)

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
            allow_single_file = True,
            default = "@cgrindel_bazel_starlib//rules/private:decompress.sh.tmpl",
        ),
    },
    doc = "",
)
