"""Bazel Version Declarations"""

CURRENT_BAZEL_VERSION = "//:.bazelversion"

OTHER_BAZEL_VERSIONS = [
    "5.4.0",
]

SUPPORTED_BAZEL_VERSIONS = [
    CURRENT_BAZEL_VERSION,
] + OTHER_BAZEL_VERSIONS
