load(":stardoc_for_prov.bzl", "stardoc_for_provs")
load("//updatesrc:defs.bzl", "updatesrc_diff_and_update")

def doc_for_provs(doc_provs):
    """Defines targets for generating documentation, testing that the generated doc matches the workspace directory, and copying the generated doc to the workspace directory.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
    """
    stardoc_for_provs(doc_provs = doc_provs)

    srcs = []
    outs = []
    for doc_prov in doc_provs:
        srcs.append(doc_prov.doc_basename)
        outs.append(doc_prov.out_basename)

    updatesrc_diff_and_update(
        srcs = srcs,
        outs = outs,
    )
