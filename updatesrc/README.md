# Update Source File Rules for Bazel

This repository contains [Bazel](https://bazel.build/) rules and macros that copy files from the
Bazel output directories to the workspace directory.

Have you ever wanted to copy the output of a Bazel build step to your source directory (e.g.,
generated documentation, formatted source files)? Instead of recreating the logic to perform this
trick in every Bazel project, try using the
[updatesrc_update](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update) rule and the
[updatesrc_update_all](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update_all) macro.

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
    "@cgrindel_bazel_starlib//updatesrc:updatesrc.bzl",
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

## Learn More

- [How to Use `updatesrc`](/doc/updatesrc/how_to.md)
- Check out [the examples](/examples/updatesrc/)
- Peruse [the documentation](/doc/updatesrc/)
