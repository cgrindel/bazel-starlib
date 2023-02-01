# Bazel Starlib

[![Build](https://github.com/cgrindel/bazel-starlib/actions/workflows/ci.yml/badge.svg?event=schedule)](https://github.com/cgrindel/bazel-starlib/actions/workflows/ci.yml)

Bazel Starlib is a collection of projects that contain rulesets and libraries that are useful for
the implementation of Bazel projects. 

| Project | Description | Documentation |
| ------- | ----------- | ------------- |
| bazeldoc | Generate Starlark documentation using [Bazel Stardoc](https://github.com/bazelbuild/stardoc). Formerly hosted as [bazel-doc](https://github.com/cgrindel/bazel-doc). | [API](/doc/bazeldoc/), [How-to](/bazeldoc/) |
| bzlformat | Format Bazel Starlark files using [Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier), test that the formatted files exist in the workspace directory, and copy formatted files to the workspace directory. Formerly hosted as [rules_bzlformat](https://github.com/cgrindel/rules_bzlformat). | [API](/doc/bzlformat/), [How-to](/bzlformat/), [Examples](/examples/bzlformat/) |
| bzllib | Collection of Starlark libraries. | [API](/doc/bzllib/), [How-to](/bzllib/) |
| bzlrelease | Automate and customize the generation of releases using GitHub Actions. | [API](/doc/bzlrelease/), [How-to](/bzlrelease/) |
| markdown | Maintain markdown files. | [API](/doc/markdown/), [How-to](/markdown/), [Examples](/examples/markdown/) |
| shlib | Collection of libraries useful when implementing shell binaries, libraries, and tests. Formerly hosted as [bazel_shlib](https://github.com/cgrindel/bazel_shlib). | [API](/doc/shlib/), [How-to](/shlib/) |
| updatesrc | Copy files from the Bazel output directories to the workspace directory. Formerly hosted as [rules_updatesrc](https://github.com/cgrindel/rules_updatesrc) | [API](/doc/updatesrc/), [How-to](/updatesrc/), [Examples](/examples/updatesrc/) |


## Table of Contents

<!-- MARKDOWN TOC: BEGIN -->
* [Quickstart](#quickstart)
  * [Workspace Configuration](#workspace-configuration)
* [Other Documentation](#other-documentation)
<!-- MARKDOWN TOC: END -->


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
    sha256 = "b4c92b66569c3371c08ef359883600c46bd51951e453cf12daa3b062ebea368a",
    urls = [
        "https://github.com/cgrindel/bazel-starlib/releases/download/v0.11.1-beta/bazel-starlib.v0.11.1-beta.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
```
<!-- END WORKSPACE SNIPPET -->

## Other Documentation

- [Release process for this repository](release/README.md)
