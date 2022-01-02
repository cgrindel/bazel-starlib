# Bazel Starlib

Bazel Starlib is a collection of rulesets and libraries that are useful for the implementation of
Bazel projects. This repository contains the following projects:

- [bazeldoc](/bazeldoc/README.md) - Generate Starlark documentation using [Bazel
  Stardoc](https://github.com/bazelbuild/stardoc). Formerly hosted as [bazel-doc](https://github.com/cgrindel/bazel-doc).
- [bzlformat](/bzlformat/README.md) - Format Bazel Starlark files using
  [Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier), test that the
  formatted files exist in the workspace directory, and copy formatted files to the workspace
  directory. Formerly hosted as [rules_bzlformat](https://github.com/cgrindel/rules_bzlformat).
- [bzllib](/bzllib/README.md) - Collection of Starlark libraries.
- [bzlrelease](/bzlrelease/README.md) - Automate and customize the generation of releases using
  GitHub Actions.
- [shlib](/shlib/README.md) - Collection of libraries useful when implementing shell binaries,
  libraries, and tests. Formerly hosted as [bazel_shlib](https://github.com/cgrindel/bazel_shlib).
- [updatesrc](/updatesrc/README.md) - Copy files from the Bazel output directories to the
  workspace directory. Formerly hosted as [rules_updatesrc](https://github.com/cgrindel/rules_updatesrc)


## Quickstart

The following provides a quick introduction on how to load this repository into your workspace.  For
more information on how to use the projects from this repository in your workspace, check out the
how-to links above and review the [the generated documentation](/doc/).

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

- [Release process for this repository](release/README.md)
