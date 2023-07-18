"""Implementatio for `tidy_all`."""

def tidy_all(name):
    native.sh_binary(
        name = name,
        srcs = ["@cgrindel_bazel_starlib//bzltidy/private:tidy_all.sh"],
        deps = [
            "@cgrindel_bazel_starlib//shlib/lib:fail",
        ],
    )
