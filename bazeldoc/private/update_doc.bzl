load("//updatesrc:defs.bzl", "updatesrc_update")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def update_doc(doc_provs, name = "update"):
    """Defines an executable target that copies the documentation from the output directory to the workspace directory.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
    """
    srcs = []
    outs = []
    for doc_prov in doc_provs:
        srcs.append(doc_prov.doc_basename)
        outs.append(doc_prov.out_basename)

    updatesrc_update(
        name = name,
        srcs = srcs,
        outs = outs,
    )
