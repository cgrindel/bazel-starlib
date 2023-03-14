"""Definition for doc_for_provs macro."""

load("//updatesrc:defs.bzl", "updatesrc_diff_and_update")
load(":stardoc_for_prov.bzl", "stardoc_for_provs")

def doc_for_provs(doc_provs, **kwargs):
    """Defines targets for generating documentation, testing that the generated doc matches the workspace directory, and copying the generated doc to the workspace directory.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
        **kwargs: Common attributes that are applied to the underlying rules.
    """
    stardoc_for_provs(doc_provs = doc_provs, **kwargs)

    srcs = []
    outs = []
    for doc_prov in doc_provs:
        srcs.append(doc_prov.doc_basename)
        outs.append(doc_prov.out_basename)

    updatesrc_diff_and_update(
        srcs = srcs,
        outs = outs,
        **kwargs
    )
