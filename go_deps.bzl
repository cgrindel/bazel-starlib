"""Module that contains functions specifying the Golang dependencies for the \
bazel-starlib repository.
"""

load("@bazel_gazelle//:deps.bzl", "go_repository")

# NOTE: The go_repository declarations must be kept in sync with the go_deps.module() declarations
# in MODULE.bazel.

def bazel_starlib_go_dependencies():
    """Specifies the Golang dependencies for the bazel-starlib repository."""
    go_repository(
        name = "com_github_alecthomas_assert",
        build_external = "external",
        importpath = "github.com/alecthomas/assert",
        sum = "h1:smF2tmSOzy2Mm+0dGI2AIUHY+w0BUc+4tn40djz7+6U=",
        version = "v0.0.0-20170929043011-405dbfeb8e38",
    )
    go_repository(
        name = "com_github_alecthomas_colour",
        build_external = "external",
        importpath = "github.com/alecthomas/colour",
        sum = "h1:nOE9rJm6dsZ66RGWYSFrXw461ZIt9A6+nHgL7FRrDUk=",
        version = "v0.1.0",
    )
    go_repository(
        name = "com_github_alecthomas_repr",
        build_external = "external",
        importpath = "github.com/alecthomas/repr",
        sum = "h1:8Uy0oSf5co/NZXje7U1z8Mpep++QJOldL2hs/sBQf48=",
        version = "v0.0.0-20210801044451-80ca428c5142",
    )
    go_repository(
        name = "com_github_alecthomas_template",
        build_external = "external",
        importpath = "github.com/alecthomas/template",
        sum = "h1:cAKDfWh5VpdgMhJosfJnn5/FoN2SRZ4p7fJNX58YPaU=",
        version = "v0.0.0-20160405071501-a0175ee3bccc",
    )
    go_repository(
        name = "com_github_alecthomas_units",
        build_external = "external",
        importpath = "github.com/alecthomas/units",
        sum = "h1:qet1QNfXsQxTZqLG4oE62mJzwPIB8+Tee4RNCL9ulrY=",
        version = "v0.0.0-20151022065526-2efee857e7cf",
    )
    go_repository(
        name = "com_github_davecgh_go_spew",
        build_external = "external",
        importpath = "github.com/davecgh/go-spew",
        sum = "h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=",
        version = "v1.1.1",
    )
    go_repository(
        name = "com_github_ekalinin_github_markdown_toc_go",
        build_external = "external",
        importpath = "github.com/ekalinin/github-markdown-toc.go",
        sum = "h1:6jRFt5qg61XfXZbP3SDaeTX+1OC1EgbHvRceYDmPAUE=",
        version = "v1.2.1",
    )

    go_repository(
        name = "com_github_mattn_go_isatty",
        build_external = "external",
        importpath = "github.com/mattn/go-isatty",
        sum = "h1:yVuAays6BHfxijgZPzw+3Zlu5yQgKGP2/hcQbHb7S9Y=",
        version = "v0.0.14",
    )

    go_repository(
        name = "com_github_sergi_go_diff",
        build_external = "external",
        importpath = "github.com/sergi/go-diff",
        sum = "h1:XU+rvMAioB0UC3q1MFrIQy4Vo5/4VsRDQQXHsEya6xQ=",
        version = "v1.2.0",
    )
    go_repository(
        name = "com_github_stretchr_testify",
        build_external = "external",
        importpath = "github.com/stretchr/testify",
        sum = "h1:nwc3DEeHmmLAfoZucVR881uASk0Mfjw8xYJ99tb5CcY=",
        version = "v1.7.0",
    )
    go_repository(
        name = "in_gopkg_alecthomas_kingpin_v2",
        build_external = "external",
        importpath = "gopkg.in/alecthomas/kingpin.v2",
        sum = "h1:CC8tJ/xljioKrK6ii3IeWVXU4Tw7VB+LbjZBJaBxN50=",
        version = "v2.2.4",
    )
