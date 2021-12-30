"""Defines functions for creating document provider `struct` values."""

def _create(
        name,
        stardoc_input,
        deps,
        doc_label = None,
        out_basename = None,
        doc_basename = None,
        header_label = None,
        header_basename = None,
        symbols = None,
        is_stardoc = True):
    """Create a documentation provider.

    Args:
        name: A `string` which identifies the doc output. If no `symbols`
              are provided, all of the symbols which are defined in the
              corresponding `.bzl` file are documented.
        stardoc_input: A `string` representing the input label provided to the
               `stardoc` declaration.
        deps: A `list` of deps for the stardoc rule.
        doc_label: Optional. A `string` which is the doc label name.
        out_basename: Optional. A `string` which is the basename for the
                      output file.
        doc_basename: Optional. A `string` which is the basename for the
                      final documentation file.
        header_label: Optional. A `string` which is the header label name,
                      if the header is being generated.
        header_basename: Optional. The basename (`string`) of the header
                        filename file, if one is being used.
        symbols: Optional. A `list` of symbol names that should be included
                 in the documentation.
        is_stardoc: A `bool` indicating whether a `stardoc` declaration should
                    be created.

    Returns:
      A `struct` representing a documentation provider.
    """
    if doc_label == None:
        doc_label = name + "_doc"
    if out_basename == None:
        out_basename = name + ".md_"
    if doc_basename == None:
        doc_basename = name + ".md"
    if header_label == None:
        header_label = name + "_header"
    if header_basename == None:
        header_basename = header_label + ".vm"

    return struct(
        name = name,
        stardoc_input = stardoc_input,
        deps = deps,
        doc_label = doc_label,
        out_basename = out_basename,
        doc_basename = doc_basename,
        header_label = header_label,
        header_basename = header_basename,
        symbols = symbols,
        is_stardoc = is_stardoc,
    )

providers = struct(
    create = _create,
)
