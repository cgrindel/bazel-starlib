# Release Process for Bazel-Starlib

The release process for this repository is implemented using GitHub Actions and the [bzlrelease
macros](/doc/bzlrelease/README.md). This document describes how to create a release.


## How to Create a Release

Once all of the code for a release has been merged to main, the release process can be started by
executing the `//release:create` target specifying the desired release tag (e.g. v1.2.3). To create
a release tagged with `v0.1.4`, one would run the following:

```sh
# Launch release GitHub Actions release workflow for v0.1.4
$ bazel run //release:create -- v0.1.4
```

This will launch the [release workflow](.github/workflows/create_release.yml). The workflow performs
the following steps:

1. Creates the specified tag at the HEAD of the main branch.
2. Generates release notes.
3. Creates a GitHub release.
4. Updates the `README.md` with the latest workspace snippet information.
5. Creates a PR with the updated `README.md` configured to auto-merge if all the checks pass.

There are two ways that this process could fail. First, if an improperly formatted release tag is
specified, the release workflow will fail. Be sure to prefix the release tag with `v`. Second, the
PR that contains the updates to the README.md file could fail if the PR cannot be automatically
merged. 
