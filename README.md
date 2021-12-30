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
    sha256 = "d8159803745083d352cc6b941267724c7a5c09d952b0868bd90399036fb3ccde",
    strip_prefix = "bazel-starlib-0.1.4",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/v0.1.4.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```
<!-- END WORKSPACE SNIPPET -->

## Other Documentation

- [Release Process](release/README.md)
