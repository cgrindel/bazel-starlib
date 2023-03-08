"""Bazel Version Declarations"""

CURRENT_BAZEL_VERSION = "//:.bazelversion"

OTHER_BAZEL_VERSIONS = [
    # GH195: Enable once we can use the default enable_bzlmod values (i.e., do
    # not need to specify).
    # "5.4.0",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
