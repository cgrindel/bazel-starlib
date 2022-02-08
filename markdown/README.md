# Markdown Rules

This project contains rules that aid in the maintenance of
[Markdown](https://www.markdownguide.org/) documents in your Bazel workspace.


## Table of Contents

> TODO (grindel): ADD TOC


## Quickstart

The following provides a quick introduction on how to use the rules in this project. For more
information, check out [the documentation](/doc/markdown/) and [the examples](/examples/markdown/).


### 1. Configure your workspace to use `markdown`

In addition to the [workspace snippet for the repository](/README.md#workspace-configuration), add
the following to your `WORKSPACE` file. 

```python
load("@build_bazel_rules_nodejs//:repositories.bzl", "build_bazel_rules_nodejs_dependencies")

build_bazel_rules_nodejs_dependencies()

load("@cgrindel_bazel_starlib//markdown:defs.bzl", "markdown_register_node_deps")

markdown_register_node_deps()
```
