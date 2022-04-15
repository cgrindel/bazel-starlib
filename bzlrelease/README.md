# Release Rules for Starlark Repositories

The rules and macros in this project in conjunction with the
[cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) GitHub Action are
useful for implementing a customizable release process for Bazel Starlark repositories.

The primary concept is to define executable targets that produce different artifacts of the release
process and then coordinate the execution of these targets using a GitHub Action workflow and the
[cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) action.

## Table of Contents

* [Define the Release Targets](#define-the-release-targets)
  * [Workspace Snippet Generation](#workspace-snippet-generation)
  * [Release Notes Generation](#release-notes-generation)
  * [README\.md Update](#readmemd-update)
  * [Release Creation](#release-creation)
* [GitHub Repository Configuration](#github-repository-configuration)
  * [Set Up a GitHub App to Generate Tokens](#set-up-a-github-app-to-generate-tokens)
  * [Repository Configuration for the README\.md Update Pull Request](#repository-configuration-for-the-readmemd-update-pull-request)
* [Implement the Create Release Workflow (GitHub Actions)](#implement-the-create-release-workflow-github-actions)
* [Create a Release](#create-a-release)
* [Questions and Answers](#questions-and-answers)
  * [Why not just use the softprops/action\-gh\-release action or any of the other release actions?](#why-not-just-use-the-softpropsaction-gh-release-action-or-any-of-the-other-release-actions)
  * [Why not trigger release creation on release tag pushes?](#why-not-trigger-release-creation-on-release-tag-pushes)
  * [Why not just create a release from the GitHub web application?](#why-not-just-create-a-release-from-the-github-web-application)
  * [Do I need the create\_release target?](#do-i-need-the-create_release-target)

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
that specifies the location of template file . 

```python
generate_workspace_snippet(
    name = "generate_workspace_snippet",
    template = "workspace_snippet.tmpl",
)
```

The workspace snippet template is a text file that contains the workspace snippet code.  Since the
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
<!-- markdown-link-check-disable-next-line -->
[generate_workspace_snippet.sh](bzlrelease/tools/generate_workspace_snippet.sh)


### Release Notes Generation

The release notes document is 
<!-- markdown-link-check-disable-next-line -->
[GitHub markdown](https://docs.github.com/en/github/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)
that includes a `What's Changed` section that is generated by the GitHub API and a `Workspace
Snippet` that is sourced from the output of the
[generate_workspace_snippet](/doc/bzlrelease/generate_workspace_snippet.md). An example can be seen
[here](https://github.com/cgrindel/bazel-starlib/releases/tag/v0.3.0).

The [generate_release_notes](/doc/bzlrelease/generate_release_notes.md) macro defines an executable
target that produces a release notes document. It accepts a `generate_workspace_snippet` attribute
that refers to a `generate_workspace_snippet` declaration.

```python
generate_release_notes(
    name = "generate_release_notes",
    generate_workspace_snippet = ":generate_workspace_snippet",
)
```

### README.md Update

Many Bazel Starlark repositories include a `README.md` at the root of the repository that provide a
short section describing how to download and initialize the latest release of the Starlark code in
the repository. The [update_readme](/doc/bzlrelease/update_readme.md) macro defines an executable
target that updates the `README.md` file with the latest workspace snippet code.

The macro accepts a `generate_workspace_snippet` attribute that refers to a
`generate_workspace_snippet` declaration and an optional `readme` attribute that specifies the
location of the file to update.

```python
update_readme(
    name = "update_readme",
    generate_workspace_snippet = ":generate_workspace_snippet",
)
```

For the utility to work properly, comment markers need to be added to the `README.md` file.  The
<!-- markdown-link-check-disable-next-line -->
[update_readme.sh](bzlrelease/tools/update_readme.sh) utility will replace the lines between `<!--
BEGIN WORKSPACE SNIPPET -->` and `<!-- END WORKSPACE SNIPPET -->` with the workspace snippet
generated by the `generate_workspace_snippet` utility. The following shows an example of what the
markers look like inside a markdown file.

````markdown
### Workspace Configuration

<!-- BEGIN WORKSPACE SNIPPET -->
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
<!-- END WORKSPACE SNIPPET -->
````

### Release Creation

The [create_release](/doc/bzlrelease/create_release.md) macro defines an executable target that will
launch a GitHub Actions workflow. Unlike the other targets mentioned above, this target is not used
during the release creation process. It merely provides a convenient way to kick-off the release
creation process.

The macro accepts a `workflow_name` attribute which must match the name of the GitHub Actions
workflow that executes your release process.

```python
create_release(
    name = "create",
    workflow_name = "Create Release",
)
```

## GitHub Repository Configuration

### Set Up a GitHub App to Generate Tokens

Before we can implement the release creation workflow, we need to set up a GitHub App in your
repository that has permission to create releases and pull requests.  The default Github token that
is provided to GitHub Action workflows does not have permission to create releases and PRs. This
[article from
peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request/blob/master/docs/concepts-guidelines.md#authenticating-with-github-app-generated-tokens)
explains how to create a GitHub application to generate tokens with the appropriate permissions.

Once you have created the token generator application, you need to create two secrets in your
repository. The first is named `APP_ID`. It's value is the `App ID: XXXX` value (e.g., `XXXX`) found
on the token generator application's About page. The second secret is named `APP_PRIVATE_KEY`. It's
value is the private key that you generated while creating the token generator application.

### Repository Configuration for the `README.md` Update Pull Request

The release process can update the `README.md` file at the root of the repository with the latest
workspace snippet. To ensure that the pull request that is created during this process
automatically merges to the main branch, we need to enable the `Allow auto-merge` option in your
repository's Settings > General page.

While you are on this page, you may want to enable `Automatically delete head branches`, as well.
When enabled, the branch for a merged pull request will be deleted. This bit of housekeeping keeps
the number of remote branches in your repository to a minimum.

## Implement the Create Release Workflow (GitHub Actions)

The `Create Release` workflow using the
[cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) action coordinates the
entire release process.

In your repository, create a file at `.github/workflows/create_release.yml` with the following
contents:

```yaml
name: Create Release

on:
  workflow_dispatch:
    inputs:
      release_tag:
        required: true
        type: string
      reset_tag:
        type: boolean
        default: false
      base_branch:
        description: The branch being merged to.
        type: string
        default: main

jobs:
  create_release:
    runs-on: ubuntu-latest
    env:
      CC: clang

    steps:

    # Check out your code
    - uses: actions/checkout@v2

    # Generate a token that has permssions to create a release and create PRs.
    - uses: tibdex/github-app-token@v1
      id: generate_token
      with:
        app_id: ${{ secrets.APP_ID }}
        private_key: ${{ secrets.APP_PRIVATE_KEY }}

    # Configure the git user for the repository
    - uses: cgrindel/gha_configure_git_user@v1

    # Create the release
    - uses: cgrindel/gha_create_release@v1
      with:
        release_tag: ${{  github.event.inputs.release_tag }}
        reset_tag: ${{  github.event.inputs.reset_tag }}
        base_branch: ${{  github.event.inputs.base_branch }}
        github_token: ${{ steps.generate_token.outputs.token }}
```

Commit this file, the release targets, and merge all of it to your main branch.


## Create a Release

Once everything is merged to your main branch, you can create a release by running the following
from your Bazel repository.

```sh
# Create a release with the tag v1.2.3
$ bazel run //release:create -- v1.2.3
```

This utility will launch the `create_release.yml` workflow in GitHub Actions. After a few moments,
you should see a new tag `v1.2.3`, the new release based upon the tag, and the automerge pull
request that contains your `README.md` update. 


## Questions and Answers

### Why not just use the `softprops/action-gh-release` action or any of the other release actions?

The [cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release) action uses the
following shared actions:

- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
- [peter-evans/enable-pull-request-automerge](https://github.com/peter-evans/enable-pull-request-automerge)

The primary purpose of [cgrindel/gha_create_release](https://github.com/cgrindel/gha_create_release)
is to generate the release artifacts and coordinate the different steps.

When I started this project, I had two goals:

1. Generate release notes that included the changes from the last release and included the workspace
   snippet for the release.
2. Update the `README.md` file to include the latest workspace snippet.

Since the `bzlrelease` macros are targeted at release creation for Starlark repositories, I opted to
incorporate the artifact generation in Bazel.


### Why not trigger release creation on release tag pushes?

Frankly, tagging and pushing directly to my main branch worries me. I have messed this up in the
past, pushing changes that I had not intended to push. Wrapping the tagging and release creation in
a workflow that executes in a consistent and known state feels like a much better choice to me.


### Why not just create a release from the GitHub web application?

I wanted the release notes to include specific items, as mentioned above. Also, the fewer manual
steps the better. 😀


### Do I need the `create_release` target?

No. If you don't want this helper, you can add everything else. Then, when it is time to create a
release, you can 
<!-- markdown-link-check-disable-next-line -->
[launch the release process manually](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow).
