"""Definition for write_file_list macro."""

load(":doc_utilities.bzl", "doc_utilities")
load(":write_doc.bzl", "write_doc")

def write_file_list(
        name,
        out,
        header_content = [],
        doc_provs = [],
        do_not_edit_warning = True):
    """Defines a target that writes a documentation file that contains a header and a list of files.

    Args:
        name: The name of the target.
        out: The basename of the output filename as a `string`.
        header_content: A `list` of strings representing the header content of
                        the file.
        doc_provs: A `list` of document provider `struct` values as returned
                   from `providers.create()`.
        do_not_edit_warning: A `bool` specifying whether a comment should be
                             added to the top of the written file.

    Returns:
        None.
    """
    doc_path = native.package_name()
    content = []
    content.extend(header_content)
    if doc_provs != []:
        content.extend([
            doc_utilities.toc_entry(r.name, "/{doc_path}/{src_doc}".format(
                doc_path = doc_path,
                src_doc = r.doc_basename,
            ))
            for r in doc_provs
        ])
    content.append("")

    if out == None:
        out = name + ".vm"

    write_doc(
        name = name,
        out = out,
        content = content,
        do_not_edit_warning = do_not_edit_warning,
    )
