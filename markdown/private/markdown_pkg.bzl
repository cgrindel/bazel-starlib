load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("//bzllib:defs.bzl", "src_utils")
load("//updatesrc:defs.bzl", "updatesrc_update")
load(":markdown_generate_toc.bzl", "markdown_generate_toc")

# GH086: Finish markdown_pkg implementation.

# def markdown_pkg(name = "markdown", srcs = None, toc_visibility = None, update_visibility = None):
#     if srcs == None:
#         srcs = native.glob(["*.md", "*.markdown"])

#     # Only process paths; ignore labels
#     src_paths = [src for src in srcs if src_utils.is_path(src)]

#     name_prefix = name + "_"
#     toc_names = []
#     for src in src_paths:
#         src_name = src_utils.path_to_name(src)
#         toc_name = name_prefix + src_name + "_toc"
#         toc_names.append(toc_name)
#         # toc_names.append(":" + toc_name)

#         markdown_generate_toc(
#             name = toc_name,
#             srcs = [src],
#             visibility = toc_visibility,
#         )
#         diff_test(
#             name = name_prefix + src_name + "_fmttest",
#             file1 = src,
#             # file2 = ":" + toc_name,
#             file2 = toc_name,
#         )

#     updatesrc_update(
#         name = name + "_update",
#         deps = toc_names,
#         visibility = update_visibility,
#     )
