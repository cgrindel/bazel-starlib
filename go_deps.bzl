"""Module that contains functions specifying the Golang dependencies for the \
bazel-starlib repository.
"""

load("@bazel_gazelle//:deps.bzl", "go_repository")

def bazel_starlib_go_dependencies():
    """Load dependencies for `bazel-starlib`."""

    go_repository(
        name = "com_github_creasty_defaults",
        build_external = "external",
        importpath = "github.com/creasty/defaults",
        sum = "h1:eNdqZvc5B509z18lD8yc212CAqJNvfT1Jq6L8WowdBA=",
        version = "v1.7.0",
    )
    go_repository(
        name = "com_github_davecgh_go_spew",
        build_external = "external",
        importpath = "github.com/davecgh/go-spew",
        sum = "h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=",
        version = "v1.1.1",
    )
    go_repository(
        name = "com_github_gomarkdown_markdown",
        build_external = "external",
        importpath = "github.com/gomarkdown/markdown",
        sum = "h1:saBP362Qm7zDdDXqv61kI4rzhmLFq3Z1gx34xpl6cWE=",
        version = "v0.0.0-20240626202925-2eda941fd024",
    )

    go_repository(
        name = "com_github_pmezard_go_difflib",
        build_external = "external",
        importpath = "github.com/pmezard/go-difflib",
        sum = "h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=",
        version = "v1.0.0",
    )

    go_repository(
        name = "com_github_stretchr_objx",
        build_external = "external",
        importpath = "github.com/stretchr/objx",
        sum = "h1:xuMeJ0Sdp5ZMRXx/aWO6RZxdr3beISkG5/G/aIRr3pY=",
        version = "v0.5.2",
    )
    go_repository(
        name = "com_github_stretchr_testify",
        build_external = "external",
        importpath = "github.com/stretchr/testify",
        sum = "h1:HtqpIVDClZ4nwg75+f6Lvsy/wHu+3BoSGCbBAcpTsTg=",
        version = "v1.9.0",
    )

    go_repository(
        name = "in_gopkg_check_v1",
        build_external = "external",
        importpath = "gopkg.in/check.v1",
        sum = "h1:yhCVgyC4o1eVCa2tZl7eS0r+SDo693bJlVdllGtEeKM=",
        version = "v0.0.0-20161208181325-20d25e280405",
    )
    go_repository(
        name = "in_gopkg_yaml_v3",
        build_external = "external",
        importpath = "gopkg.in/yaml.v3",
        sum = "h1:fxVm/GzAzEWqLHuvctI91KS9hhNmmWOoWu0XTYJS7CA=",
        version = "v3.0.1",
    )
