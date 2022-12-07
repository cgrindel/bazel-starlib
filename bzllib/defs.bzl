"""Public API for bzllib."""

load(
    "//bzllib/private:bazel_labels.bzl",
    _bazel_labels = "bazel_labels",
    _make_bazel_labels = "make_bazel_labels",
)
load("//bzllib/private:filter_srcs.bzl", _filter_srcs = "filter_srcs")
load("//bzllib/private:src_utils.bzl", _src_utils = "src_utils")
load(
    "//bzllib/private:workspace_name_resolvers.bzl",
    _make_stub_workspace_name_resolvers = "make_stub_workspace_name_resolvers",
    _workspace_name_resolvers = "workspace_name_resolvers",
)

src_utils = _src_utils
filter_srcs = _filter_srcs

workspace_name_resolvers = _workspace_name_resolvers
make_stub_workspace_name_resolvers = _make_stub_workspace_name_resolvers

bazel_labels = _bazel_labels
make_bazel_labels = _make_bazel_labels
