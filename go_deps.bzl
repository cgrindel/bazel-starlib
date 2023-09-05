"""Module that contains functions specifying the Golang dependencies for the \
bazel-starlib repository.
"""

load("@bazel_gazelle//:deps.bzl", "go_repository")

def bazel_starlib_go_dependencies():
    """Load dependencies for `bazel-starlib`."""
    go_repository(
        name = "com_github_alecthomas_assert",
        build_external = "external",
        importpath = "github.com/alecthomas/assert",
        sum = "h1:3XmGh/PSuLzDbK3W2gUbRXwgW5lqPkuqvRgeQ30FI5o=",
        version = "v1.0.0",
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
        name = "com_github_mattn_go_isatty",
        build_external = "external",
        importpath = "github.com/mattn/go-isatty",
        sum = "h1:yVuAays6BHfxijgZPzw+3Zlu5yQgKGP2/hcQbHb7S9Y=",
        version = "v0.0.14",
    )
    go_repository(
        name = "com_github_pmezard_go_difflib",
        build_external = "external",
        importpath = "github.com/pmezard/go-difflib",
        sum = "h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=",
        version = "v1.0.0",
    )
    go_repository(
        name = "com_github_sergi_go_diff",
        build_external = "external",
        importpath = "github.com/sergi/go-diff",
        sum = "h1:XU+rvMAioB0UC3q1MFrIQy4Vo5/4VsRDQQXHsEya6xQ=",
        version = "v1.2.0",
    )
    go_repository(
        name = "com_github_stretchr_objx",
        build_external = "external",
        importpath = "github.com/stretchr/objx",
        sum = "h1:1zr/of2m5FGMsad5YfcqgdqdWrIhu+EBEJRhR1U7z/c=",
        version = "v0.5.0",
    )
    go_repository(
        name = "com_github_stretchr_testify",
        build_external = "external",
        importpath = "github.com/stretchr/testify",
        sum = "h1:CcVxjf3Q8PM0mHUKJCdn+eZZtm5yQwehR5yeSVQQcUk=",
        version = "v1.8.4",
    )
    go_repository(
        name = "in_gopkg_alecthomas_kingpin_v2",
        build_external = "external",
        importpath = "gopkg.in/alecthomas/kingpin.v2",
        sum = "h1:CC8tJ/xljioKrK6ii3IeWVXU4Tw7VB+LbjZBJaBxN50=",
        version = "v2.2.4",
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
    go_repository(
        name = "org_golang_x_crypto",
        build_external = "external",
        importpath = "golang.org/x/crypto",
        sum = "h1:mvySKfSWJ+UKUii46M40LOvyWfN0s2U+46/jDd0e6Ck=",
        version = "v0.13.0",
    )

    go_repository(
        name = "org_golang_x_net",
        build_external = "external",
        importpath = "golang.org/x/net",
        sum = "h1:ugBLEUaxABaB5AJqW9enI0ACdci2RUd4eP51NTBvuJ8=",
        version = "v0.15.0",
    )

    go_repository(
        name = "org_golang_x_sys",
        build_external = "external",
        importpath = "golang.org/x/sys",
        sum = "h1:CM0HF96J0hcLAwsHPJZjfdNzs0gftsLfgKt57wWHJ0o=",
        version = "v0.12.0",
    )
    go_repository(
        name = "org_golang_x_term",
        build_external = "external",
        importpath = "golang.org/x/term",
        sum = "h1:/ZfYdc3zq+q02Rv9vGqTeSItdzZTSNDmfTi0mBAuidU=",
        version = "v0.12.0",
    )
    go_repository(
        name = "org_golang_x_text",
        build_external = "external",
        importpath = "golang.org/x/text",
        sum = "h1:ablQoSUd0tRdKxZewP80B+BaqeKJuVhuRxj/dkrun3k=",
        version = "v0.13.0",
    )
