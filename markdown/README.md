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
load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains", "buildtools_assets")

buildifier_prebuilt_register_toolchains()
```
