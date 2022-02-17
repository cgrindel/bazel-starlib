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
    if srcs == None:
        srcs = native.glob(["*.md", "*.markdown"])

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
