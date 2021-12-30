"""Defines utility functions for working with markdown documentation files."""

def _link(label, url):
    """Creates a markdown link.

    Args:
        label: The label for the link as a `string`.
        url: The URL for the link as a `string`.

    Returns:
        A markdown link as a `string`.
    """
    return "[{label}]({url})".format(
        label = label,
        url = url,
    )

def _toc_entry(label, url):
    """Creates table-of-contents (TOC) entry suitable for markdown documents.

    Args:
        label: The label for the link as a `string`.
        url: The URL for the link as a `string`.

    Returns:
    """
    return "  * " + _link(label, url)

doc_utilities = struct(
    link = _link,
    toc_entry = _toc_entry,
)
