# Demonstrate `markdown` Rules

This workspace demonstrates the use of `markdown_check_links_test`.

NOTE: The links in this document are meant to be relative to this child workspace, not the parent
workspace. Hence, if you navigated here from the parent workspace, the absolute paths (i.e.,
starting with a `/`) will not work properly. However, they must remain as is for the integration
tests to work properly.

- [External Link](https://bazel.build/)
- [Internal Link, same package](/foo.md)
- [Link to bar package](/bar/)


## Table of Contents

The following TOC is maintained by a
[`markdown_generate_toc`](https://github.com/cgrindel/bazel-starlib/blob/main/doc/markdown/rules_and_macros_overview.md#markdown_generate_toc)
rule that is defined by a
[`markdown_pkg`](https://github.com/cgrindel/bazel-starlib/blob/main/doc/markdown/rules_and_macros_overview.md#markdown_pkg).

<!-- MARKDOWN TOC: BEGIN -->
* [Foo](#foo)
  * [Foo Subtitle](#foo-subtitle)
* [Bar](#bar)
<!-- MARKDOWN TOC: END -->

## Foo

This section talks about foo.

### Foo Subtitle

This section talks about something specific to foo.

## Bar

