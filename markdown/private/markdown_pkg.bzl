"""Definition for markdown_pkg macro."""

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("//bzllib:defs.bzl", "src_utils")
load("//updatesrc:defs.bzl", "updatesrc_update")
load(":markdown_generate_toc.bzl", "markdown_generate_toc")

def markdown_pkg(
        name = "markdown",
        srcs = None,
        toc_visibility = None,
        update_visibility = None,
        define_doc_files = True,
        doc_files_visibility = ["@//:__subpackages__"],
        additional_doc_files = []):
    """Adds targets to maintain markdown files in the package.

    This macro adds targets to generate a table of contents (TOC) for markdown \
    files (`markdown_generate_toc`), adds `diff_test` targets to confirm that \
    the markdown files are up-to-date with the latest TOC, adds a target to \
    update the markdown files with the generated files (`updatesrc_update`) \
    and defines a `filegroup` that is useful to collecting documentation files \
    for confirming that a markdown files links are valid \
    (`markdown_check_links_test`)

    Args:
        name: A prefix `string` that will be added to all of the targets
              defined by this macro.
        srcs: Optional. The markdown sources to be used by the macro. If none
              are specified, all of the `.md` and `.markdown` files are used.
        toc_visibility: Optional. The visibility for the TOC generation targets.
        update_visibility: Optional. The visibility for the update target.
        define_doc_files: Optional. A `bool` that specifies whether to define a
                          `filegroup` that can be used for documentation
                          validity tests.
        doc_files_visibility: Optional. The visibility for the documentation
                              `filegroup` target.
        additional_doc_files: Optional. Additional files that should be
                              included in the documentation `filegroup`.
    """
    if srcs == None:
        srcs = native.glob(
            ["*.md", "*.markdown"],
            allow_empty = True,
        )

    # Only process paths; ignore labels
    src_paths = [src for src in srcs if src_utils.is_path(src)]

    # Add targets to maintain the TOC
    name_prefix = name + "_"
    toc_names = []
    for src in src_paths:
        src_name = src_utils.path_to_name(src)
        toc_name = name_prefix + src_name + "_toc"
        toc_names.append(toc_name)

        markdown_generate_toc(
            name = toc_name,
            srcs = [src],
            visibility = toc_visibility,
        )
        diff_test(
            name = name_prefix + src_name + "_toctest",
            file1 = src,
            file2 = toc_name,
        )

    updatesrc_update(
        name = name + "_update",
        deps = toc_names,
        visibility = update_visibility,
    )

    if define_doc_files:
        native.filegroup(
            name = name + "_doc_files",
            srcs = srcs + additional_doc_files,
            visibility = doc_files_visibility,
        )
