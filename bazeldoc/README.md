# Macros for Generating Starlark Documentation

This project contains macros and APIs that reduce some of the boilerplate when generating
documentation for Starlark code.

## Reference Documentation

[Click here](/doc/bazeldoc/) for reference documentation for the rules and other definitions.

## Quickstart

### 1. Configure your workspace to use `bazeldoc`

In addition to the [workspace snippet for the repository](/README.md#workspace-configuration), add
the following to your `WORKSPACE` file:

```python
load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```


### 2. Review sample implementations

Look at the BUILD.bazel files in the documentation directories (e.g.
[bazeldoc](/doc/bazeldoc/BUILD.bazel), [bzlformat](/doc/bzlformat/BUILD.bazel)). They use the macros
and APIs defined in this project.

