# Bazel Starlib

[![Build](https://github.com/cgrindel/bazel-starlib/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/cgrindel/bazel-starlib/actions/workflows/ci.yml)

Bazel Starlib is a collection of projects that contain rulesets and libraries that are useful for
the implementation of Bazel projects.

| Project    | Description                                                                                                                                                                                                                                                                                                              | Documentation                                                                   |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| bazeldoc   | Generate Starlark documentation using [Bazel Stardoc](https://github.com/bazelbuild/stardoc). Formerly hosted as [bazel-doc](https://github.com/cgrindel/bazel-doc).                                                                                                                                                     | [API](/doc/bazeldoc/), [How-to](/bazeldoc/)                                     |
| bzlformat  | Format Bazel Starlark files using [Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier), test that the formatted files exist in the workspace directory, and copy formatted files to the workspace directory. Formerly hosted as [rules_bzlformat](https://github.com/cgrindel/rules_bzlformat). | [API](/doc/bzlformat/), [How-to](/bzlformat/), [Examples](/examples/bzlformat/) |
| bzllib     | Collection of Starlark libraries.                                                                                                                                                                                                                                                                                        | [API](/doc/bzllib/), [How-to](/bzllib/)                                         |
| bzlrelease | Automate and customize the generation of releases using GitHub Actions.                                                                                                                                                                                                                                                  | [API](/doc/bzlrelease/), [How-to](/bzlrelease/)                                 |
| bzltidy    | Collect Bazel actions that keep your source files up-to-date.                                                                                                                                                                                                                                                            | [API](/doc/bztidy/), [How-to](/bzltidy/)                                        |
| markdown   | Maintain markdown files.                                                                                                                                                                                                                                                                                                 | [API](/doc/markdown/), [How-to](/markdown/), [Examples](/examples/markdown/)    |
| shlib      | Collection of libraries useful when implementing shell binaries, libraries, and tests. Formerly hosted as [bazel_shlib](https://github.com/cgrindel/bazel_shlib).                                                                                                                                                        | [API](/doc/shlib/), [How-to](/shlib/)                                           |
| updatesrc  | Copy files from the Bazel output directories to the workspace directory. Formerly hosted as [rules_updatesrc](https://github.com/cgrindel/rules_updatesrc)                                                                                                                                                               | [API](/doc/updatesrc/), [How-to](/updatesrc/), [Examples](/examples/updatesrc/) |

## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->

- [Quickstart](#quickstart)
  - [Workspace Configuration](#workspace-configuration)
- [Other Documentation](#other-documentation)
<!-- MARKDOWN TOC: END -->

## Quickstart

The following provides a quick introduction on how to load this repository into your workspace. For
more information on how to use the projects from this repository in your workspace, check out the
how-to links above and review the [the generated documentation](/doc/).

### `MODULE.bazel` Snippet

<!-- BEGIN MODULE SNIPPET -->
```python
bazel_dep(name = "cgrindel_bazel_starlib", version = "0.20.2")
```
<!-- END MODULE SNIPPET -->

### Workspace Configuration

<!-- BEGIN WORKSPACE SNIPPET -->
```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "1749e14037e67cfeaf28b71334ef4ade7727edaafc890f8cee7648939eae77d4",
    urls = [
        "https://github.com/cgrindel/bazel-starlib/releases/download/v0.20.2/bazel-starlib.v0.20.2.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
```
<!-- END WORKSPACE SNIPPET -->

## Developer Documentation

### To Add a Golang Dependency

Execute the following to update the go module files, resolve the Golang dependencies and update the
Bazel build files.

```sh
$ bazel run @io_bazel_rules_go//go -- github.com/sweet/go_pkg
$ bazel run //:go_mod_tidy
$ bazel run //:gazelle_update_repos
$ bazel run //:update_build_files
```

## Other Documentation

- [Release process for this repository](release/README.md)
