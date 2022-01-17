# Buildifier Rules for Bazel

This project contains Bazel rules and macros that format Bazel Starlark files (e.g. `.bzl`,
`BUILD`, `BUILD.bazel`) using
[Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier), test that the
formatted files exist in the workspace directory, and copy the formatted files to the workspace
directory.

## Table of Contents

* [Quickstart](#quickstart)
  * [1\. Configure your workspace to use bzlformat](#1-configure-your-workspace-to-use-bzlformat)
  * [2\. Update the BUILD\.bazel at the root of your workspace](#2-update-the-buildbazel-at-the-root-of-your-workspace)
  * [3\. Add bzlformat\_pkg to every Bazel package](#3-add-bzlformat_pkg-to-every-bazel-package)
  * [4\. Format, Update, and Test](#4-format-update-and-test)
  * [5\. (Optional) Update Your CI Test Runs](#5-optional-update-your-ci-test-runs)

## Quickstart

The following provides a quick introduction on how to use the rules in this repository. Also, check
out [the documentation](/doc/bzlformat/) and [the examples](/examples/) for more information.

### 1. Configure your workspace to use `bzlformat`

In addition to the [workspace snippet for the repository](/README.md#workspace-configuration), add
the following to your `WORKSPACE` file. These are dependencies for
[Buildifier](https://github.com/bazelbuild/buildtools/tree/master/buildifier).

```python
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.2")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
```

### 2. Update the `BUILD.bazel` at the root of your workspace

At the root of your workspace, create a `BUILD.bazel` file, if you don't have one. Add the
following:

```python
load(
    "@cgrindel_bazel_starlib//bzlformat:defs.bzl",
    "bzlformat_missing_pkgs",
    "bzlformat_pkg",
)
load(
    "@cgrindel_bazel_starlib//updatesrc:defs.bzl",
    "updatesrc_update_all",
)

# Ensures that the Starlark files in this package are formatted properly.
bzlformat_pkg(
    name = "bzlformat",
)

# Provides targets to find, test, and fix any Bazel packages that are missing bzlformat_pkg
# declarations.
#
# bzlformat_missing_pkgs_find: Find and report any Bazel packages that missing the bzlformat_pkg
#                              declaration.
# bzlformat_missing_pkgs_test: Like find except it fails if any missing packages are found. This is
#                              useful to run in CI tests to ensure that all is well.
# bzlformat_missing_pkgs_fix: Adds bzlformat_pkg declarations to any packages that are missing
#                             the declaration.
bzlformat_missing_pkgs(
    name = "bzlformat_missing_pkgs",
)

# Define a runnable target to execute all of the updatesrc_update targets
# that are defined in your workspace.
updatesrc_update_all(
    name = "update_all",
    targets_to_run = [
        # Fix the Bazel packages when we update our source files from build outputs.
        ":bzlformat_missing_pkgs_fix",
    ],
)
```

The [`bzlformat_pkg`](/doc/bzlformat/rules_and_macros_overview.md#bzlformat_pkg) macro defines targets for a
Bazel package that will format the Starlark source files, test that the formatted files are in the
workspace directory and copies the formatted files to the workspace directory.

The [`bzlformat_missing_pkgs`](/doc/bzlformat/rules_and_macros_overview.md#bzlformat_missing_pkgs) macro
defines executable targets that find, test, and fix Bazel packages that are missing a
`bzlformat_pkg` declaration.

The
[`updatesrc_update_all`](/doc/updatesrc/rules_and_macros_overview.md#updatesrc_update_all)
macro defines a runnable target that copies all of the formatted Starlark source files to the
workspace directory. We add a reference to the `:bzlformat_missing_pkgs_fix` target to fix the
appropriate Bazel packages when `bazel run //:update_all` is executed.

### 3. Add `bzlformat_pkg` to every Bazel package

Next, we need to add `bzlformat_pkg` declarations to every Bazel package. The quickest way to do so
is to execute `bazel run //:bzlformat_missing_pkgs_fix` or `bazel run //:update_all`.

```sh
# Update the world including any bzlformat_pkg fixes
$ bazel run //:update_all
```

### 4. Format, Update, and Test

From the command-line, you can format the Starlark source files, copy them back to the workspace
directory and execute the tests that ensure the formatted soures are in the workspace directory.

```sh
# Format the Starlark source files and copy the formatted files back to the workspace directory
$ bazel run //:update_all

# Execute all of your tests including the formatting checks
$ bazel test //...
```

### 5. (Optional) Update Your CI Test Runs

To ensure that all of your Bazel packages are monitored by `bzlformat`, add a call to `bazel
run //:bzlformat_missing_pkgs_test` to your CI test runs. If any Bazel packages are missing
`bzlformat_pkg` declarations, this executable target will exit with a non-zero value.

```sh
# Add this to your CI test runs.
$ bazel run //:bzlformat_missing_pkgs_test
```
