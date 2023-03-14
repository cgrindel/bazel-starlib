"""Defintion for stardoc_for_prov and stardoc_for_provs macros."""

load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

def stardoc_for_prov(doc_prov, **kwargs):
    """Defines a `stardoc` target for a document provider.

    Args:
        doc_prov: A `struct` as returned from `providers.create()`.
        **kwargs: Common attributes that are applied to the underlying rules.

    Returns:
        None.
    """
    target_compatible_with = kwargs.pop("target_compatible_with", select({
        "//bzlmod:is_enabled": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }))

    stardoc(
        name = doc_prov.name,
        out = doc_prov.out_basename,
        header_template = doc_prov.header_basename,
        input = doc_prov.stardoc_input,
        symbol_names = doc_prov.symbols,
        deps = doc_prov.deps,
        target_compatible_with = target_compatible_with,
    )

def stardoc_for_provs(doc_provs):
    """Defines a `stardoc` for each of the provided document providers.

    Args:
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
    """
    for doc_prov in doc_provs:
        if doc_prov.is_stardoc:
            stardoc_for_prov(
                doc_prov = doc_prov,
            )
