# Release Rules for Starlark Repositories

The rules and macros in this project in conjunction with the
[cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) GitHub Action are
useful for implementing a customizable release process for Bazel Starlark repositories.

The primary concept is to define executable targets that produce different artifacts of the release
process and then coordinate the execution of these targets using a GitHub Action workflow and the
[cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) action.

## Define the Release Targets

First, you need to select a location to define the `bzlrelease` targets. For the purposes of this
tutorial, we will use `//release`. 

There are four target types that we will define:

1. [generate_workspace_snippet](/doc/bzlrelease/generate_workspace_snippet.md) - Generates a
   workspace snippet. 
2. [generate_release_notes](/doc/bzlrelease/generate_release_notes.md) - Generates the notes that
   are included with a GitHub release.
3. [update_readme](/doc/bzlrelease/update_readme.md) - Edits the primary `README.md` file updating
   it with the workspace snippet.
4. [create_release](/doc/bzlrelease/create_release.md) - Launches a GitHub Action workflow that
   coordinates the creation of the release.

The `BUILD.bazel` file for a set of release targets will typically look like the following:

```python
load(
    "@cgrindel_bazel_starlib//bzlrelease:defs.bzl",
    "create_release",
    "generate_release_notes",
    "generate_workspace_snippet",
    "update_readme",
)

# MARK: - Release

generate_workspace_snippet(
    name = "generate_workspace_snippet",
    template = "workspace_snippet.tmpl",
)

generate_release_notes(
    name = "generate_release_notes",
    generate_workspace_snippet = ":generate_workspace_snippet",
)

update_readme(
    name = "update_readme",
    generate_workspace_snippet = ":generate_workspace_snippet",
)

create_release(
    name = "create",
    workflow_name = "Create Release",
)
```

The subsequent sections provide more detail about each of the declarations.


### Workspace Snippet Generation

A workspace snippet contains the Starlark code that is required to download and initialize your
repository along with all of its dependencies. It looks something like the following:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "5b36e7f11bf0c1d52480f1b022430611b402b5424979f280f13c52550de76584",
    strip_prefix = "bazel-starlib-0.3.0",
    urls = [
        "http://github.com/cgrindel/bazel-starlib/archive/v0.3.0.tar.gz",
    ],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```

The [generate_workspace_snippet](/doc/bzlrelease/generate_workspace_snippet.md) macro defines a
target that when executed generates a workspace snippet. The macro accepts a `template` argument
that specifies the location of a text file that contains the workspace snippet code. Since the
`http_archive` statement changes for each release, the `http_archive` statement in the template is
replaced by a placeholder, `${http_archive_statement}`. The template for the above snippet looks
like this:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

${http_archive_statement}

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```

To learn more about how the utility works, check out
[generate_workspace_snippet.sh](bzlrelease/tools/generate_workspace_snippet.sh)
