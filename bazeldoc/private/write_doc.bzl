load("@bazel_skylib//rules:write_file.bzl", "write_file")

def write_doc(name, out, content = [], do_not_edit_warning = True):
    """Writes a documentation file with the specified content.

    Args:
        name: The name of the target.
        out: The basename of the output filename as a `string`.
        content: A `list` of strings representing the content of the file.
        do_not_edit_warning: A `bool` specifying whether a comment should be
                             added to the top of the written file.

    Returns:
        None.
    """
    final_content = []
    if do_not_edit_warning:
        final_content.append("<!-- Generated with Stardoc, Do Not Edit! -->")
    final_content.extend(content)
    final_content.append("")

    write_file(
        name = name,
        out = out,
        content = final_content,
    )
