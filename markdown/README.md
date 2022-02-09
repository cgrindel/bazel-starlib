# Markdown Rules

This project contains rules that aid in the maintenance of
[Markdown](https://www.markdownguide.org/) documents in your Bazel workspace.


## Table of Contents

* [Quickstart for Markdown Link Validation](#quickstart-for-markdown-link-validation)
  * [1\. Configure your workspace to use markdown](#1-configure-your-workspace-to-use-markdown)
  * [2\. Add filegroup targets to collect the documentation files](#2-add-filegroup-targets-to-collect-the-documentation-files)
  * [3\. Create one or more markdown\_check\_links\_test targets](#3-create-one-or-more-markdown_check_links_test-targets)
  * [3\. Execute your tests\.](#3-execute-your-tests)
* [Configuring Markdown Link Validation](#configuring-markdown-link-validation)


## Quickstart for Markdown Link Validation

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


### 2. Add `filegroup` targets to collect the documentation files

In every package that contains markdown files (.md, .markdown) or files referenced by markdown
files, add a [filegroup](https://docs.bazel.build/versions/main/be/general.html#filegroup) to
collect the files.

```python
# Collect the files related to the documentation.
filegroup(
    name = "doc_files",
    srcs = glob(["*.md"]),
    visibility = ["//tests:__subpackages__"],
)
```

### 3. Create one or more `markdown_check_links_test` targets

Wherever you would like to define the
[`markdown_check_links_test`](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test)
targets, create a [filegroup](https://docs.bazel.build/versions/main/be/general.html#filegroup) to
collect all of the documentation files and define one or more test targets.

In the following snippet, we collect all of the documentation files in a
[filegroup](https://docs.bazel.build/versions/main/be/general.html#filegroup) called
`all_doc_files`. These files are passed to
[`markdown_check_links_test`](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test)
via the `data` attribute.  This results in all of the markdown files that exist in `all_doc_files`
being checked for valid links.

```python
load("@cgrindel_bazel_starlib//markdown:defs.bzl", "markdown_check_links_test")

filegroup(
    name = "all_doc_files",
    srcs = [
        "//:doc_files",
        "//bar:doc_files",
    ],
)

markdown_check_links_test(
    name = "check_links",
    data = [":all_doc_files"],
)
```

If you would prefer to specify which markdown files to test, you can do so by specifying the files
to test in the `srcs` attribute. In the following example, only the `README.md` file at the root of
the workspace is checked.

```python
load("@cgrindel_bazel_starlib//markdown:defs.bzl", "markdown_check_links_test")

filegroup(
    name = "all_doc_files",
    srcs = [
        "//:doc_files",
        "//bar:doc_files",
    ],
)

markdown_check_links_test(
    name = "check_links",
    # The README.md at the root of the workspace would need to be visible to 
    # this test target.
    srcs = ["//:README.md"],
    # The entire set of documentation files is still passed as data so that 
    # the link check can find the files that may be referenced in README.md.
    data = [":all_doc_files"],
)
```


### 3. Execute your tests.

Running `bazel test //...` will execute the
[`markdown_check_links_test`](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test)
targets. If any links are invalid, the files that have the bad links and the link itself are
reported.


## Configuring Markdown Link Validation

The
[`markdown_check_links_test`](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test)
rule uses [markdown-link-check](https://github.com/tcort/markdown-link-check) to perform the link
validation. The [markdown-link-check](https://github.com/tcort/markdown-link-check) utility can be
customized using [a configuration
file](https://github.com/tcort/markdown-link-check#config-file-format). The
[`markdown_check_links_test`](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test)
rule provides a default configuration that should be a good start for validating links in your
GitHub repository. If you would like to provide your own configuration file, you can specify it
using the [config](/doc/markdown/rules_and_macros_overview.md#markdown_check_links_test-config)
attribute.

The remainder of this section describes the settings that are specified in the default configuration
file.

```json
{
  "ignorePatterns": [
    {
      "pattern": "^#"
    }
  ],
  "replacementPatterns": [
    {
      "pattern": "^/",
      "replacement": "{{BASEURL}}/"
    },
    {
      "pattern": "^/(.*)/$",
      "replacement": "$1/README.md"
    }
  ]
}

```

The `ignorePatterns` section contains a pattern (`^#`) that ignores any links that are internal to a
document. There are [several
issues](https://github.com/tcort/markdown-link-check/issues?q=is%3Aissue+internal+links) that are
tracking better handling for these types of links.

The `replacementPatterns` section provides a means to help the utility support different URL
patterns.
- The `^/` pattern detects links that are relative to the repository root and replaces it with the
  base URL.
- The `^/(.*)/$` pattern looks for any repository relative links that end with a slash (`/`) and
  replaces them with `/README.md`. This mimics the behavior that GitHub provides.

