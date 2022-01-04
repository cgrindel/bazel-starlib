# Update Source File Rules for Bazel

This repository contains [Bazel](https://bazel.build/) rules and macros that copy files from the
Bazel output directories to the workspace directory.

Have you ever wanted to copy the output of a Bazel build step to your source directory (e.g.,
generated documentation, formatted source files)? Instead of recreating the logic to perform this
trick in every Bazel project, try using the
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) rule and the
[updatesrc_update_all](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update_all) macro.

## Table of Contents

* [Quickstart](#quickstart)
  * [1\. Configure your workspace](#1-configure-your-workspace)
  * [2\. Update the BUILD\.bazel at the root of your workspace](#2-update-the-buildbazel-at-the-root-of-your-workspace)
  * [3\. Add updatesrc\_update to every Bazel package that has files to copy](#3-add-updatesrc_update-to-every-bazel-package-that-has-files-to-copy)
  * [4\. Execute the Update All Target](#4-execute-the-update-all-target)
* [How to Ensure Workspace Files Are Up\-to\-Date](#how-to-ensure-workspace-files-are-up-to-date)
* [Learn More](#learn-more)

## Quickstart

The following provides a quick introduction on how to use the rules in this project. Also, check out
[the documentation](/doc/updatesrc/) and [the examples](/examples/updatesrc/) for more information.

### 1. Configure your workspace

[Add the workspace snippet for the repository to your `WORKSPACE` file.](/README.md#workspace-configuration)

### 2. Update the `BUILD.bazel` at the root of your workspace

At the root of your workspace, create a `BUILD.bazel` file, if you don't have one. Add the
following:

```python
load(
    "@cgrindel_bazel_starlib//updatesrc:defs.bzl",
    "updatesrc_update_all",
)

# Define a runnable target to execute all of the updatesrc_update targets
# that are defined in your workspace.
updatesrc_update_all(
    name = "update_all",
)
```

### 3. Add `updatesrc_update` to every Bazel package that has files to copy

In every Bazel package that contains source files that should be updated from build output, add a
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) declaration. For more
information on how to configure the declaration check out the [documentation](/doc/updatesrc/) and the
[examples](/examples/updatesrc/).

```python
load(
    "@cgrindel_bazel_starlib//updatesrc:defs.bzl",
    "updatesrc_update",
)

updatesrc_update(
    name = "update",
    # ...
)
```

### 4. Execute the Update All Target

To execute all of the
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) targets, run the
update all target at the root of your workspace.

```sh
$ bazel run //:update_all
```

## How to Ensure Workspace Files Are Up-to-Date

If you are using [updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) to
copy build outputs back to your workspace directory. You probably want to incorporate a check in
your build to ensure that the workspace files match what is output by the build. With a single
declaration, the
[updatesrc_diff_and_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_diff_and_update)
macro defines a single
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) target along with a
[diff_test](https://github.com/bazelbuild/bazel-skylib/blob/main/docs/diff_test_doc.md) target for
each of the source-output pairs that are specified. Just use
[updatesrc_diff_and_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_diff_and_update)
wherever you would use
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update).

```python
load("//updatesrc:defs.bzl", "updatesrc_diff_and_update")

srcs = ["foo.txt", "bar.txt"]
outs = [f + "_formatted" for f in srcs]

genrule(
  name = "format_srcs",
  srcs = srcs,
  outs = outs,
  cmd = "...",
)

# Defines the following:
#   :update - updatesrc_update target that will copy the outs to the srcs.
#   :foo.txt_difftest - diff_test for foo.txt
#   :bar.txt_difftest - diff_test for bar.txt
updatesrc_diff_and_update(
  srcs = srcs,
  outs = outs,
)
```

NOTE: The
[updatesrc_diff_and_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_diff_and_update)
macro only works with source-output pairs. It does not support update mappings specified by rules
that output [UpdateSrcsInfo](/doc/updatesrc/providers_overview.md#UpdateSrcsInfo).

Thanks to @lukedirtwalker for suggesting this feature.


## Learn More

- [How to Use `updatesrc`](/doc/updatesrc/how_to.md)
- Check out [the examples](/examples/updatesrc/)
- Peruse [the documentation](/doc/updatesrc/)
