# Starlib

Starlib is a library of Starlark APIs and rules that are useful for the implementation of Bazel
projects, but do not exist in the [Skylib](https://github.com/bazelbuild/bazel-skylib) repository.

## Quickstart

The following provides a quick introduction on how to get started using the rules and APIs in this
repository. Check out [the documentation](/doc/) for more information.

### Workspace Configuration

<!-- BEGIN WORKSPACE SNIPPET -->
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "df058f8a8500c90a178c6b6cd741b9d1d02dde41da075db4aa4a9a43dfc49905",
    strip_prefix = "bazel-starlib-999.9.9",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/v999.9.9.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@cgrindel_bazel_doc//bazeldoc:deps.bzl", "bazeldoc_dependencies")

bazeldoc_dependencies()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```
<!-- END WORKSPACE SNIPPET -->
