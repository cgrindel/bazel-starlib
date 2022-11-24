# Tidy Rules for Bazel Workspaces

This project contains a macro, called `tidy`, that defines two targets. The first target will
execute the specified Bazel targets. The second target will execute the first target and check for
any changes to the source tree. If changes are detected, execution will fail with information about
the differences detected.

## Quickstart

The followig provides a quick introduction on how to use the `tidy` macro. Also, check
out [the documentation](/doc/bzltidy/) and the use of the macro in the root `BUILD.bazel`
file in this repository.

### 1. Configure your workspace.

There is no special configuration for the `WORKSPACE` file beyond the [workspace snippet for the
repository](/README.md#workspace-configuration).

### 2. Update the `BUILD.bazel` at the root of your workspace

At the root of your workspace, create a `BUILD.bazel` file, if you don't have one. Add the
following, replacing the `targets` list with your own targets:

```python
load("@cgrindel_bazel_starlib//bzltidy:defs.bzl", "tidy")

tidy(
    name = "tidy",
    targets = [
        # Replace this list with the source-modifying targets that should be executed.
        "@contrib_rules_bazel_integration_test//tools:update_deleted_packages",
        ":bzlformat_missing_pkgs_fix",
        ":update_all",
        ":go_mod_tidy",
        ":gazelle_update_repos",
        ":gazelle",
    ],
)
```

The `tidy` macro defines two targets: `tidy` and `tidy_check`. The target named `tidy` executes the
specified targets. The target named `tidy_check` executes `tidy` and checks for any changes in the
source tree.

### 3. Tidy up your code

Now, you can run the following to ensure that your source tree is up-to-date:

```sh
# Tidy up your source tree
$ bazel run //:tidy
```

### 4. (Optional) Udpate your CI to ensure that your CI is up-to-date

To ensure that your source tree is up-to-date with every code change, add a call to `//:tidy_check`.

```sh
# Ensure that the files in the source tree are up-to-date
$ bazel run //:tidy_check
```

If files are not up-to-date, this will fail with a non-zero exit code and it will output information
about the differences that are found.
