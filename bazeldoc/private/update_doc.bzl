load("@bazel_skylib//rules:write_file.bzl", "write_file")

def update_doc(doc_provs, doc_path = "doc"):
    """Defines an executable target that copies the documentation from the output directory to the workspace directory.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
        doc_path: The relative path for the documentation directory. Do not
                  include a leading or trailing slash.

    Returns:
        None.
    """
    write_file(
        name = "gen_update",
        out = "update.sh",
        content = [
            "#!/usr/bin/env bash",
            "cd $BUILD_WORKSPACE_DIRECTORY",
        ] + [
            "cp -fv bazel-bin/{doc_path}/{gen_doc} {doc_path}/{src_doc}".format(
                doc_path = doc_path,
                gen_doc = doc_prov.out_basename,
                src_doc = doc_prov.doc_basename,
            )
            for doc_prov in doc_provs
        ],
    )

    native.sh_binary(
        name = "update",
        srcs = ["update.sh"],
        data = [doc_prov.out_basename for doc_prov in doc_provs],
        # The '@' in the following visibility is important. It makes the
        # target visible relative to the repository where it is being used.
        visibility = ["@//visibility:public"],
    )
