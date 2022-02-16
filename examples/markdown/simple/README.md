# Demonstrate `markdown` Rules

This workspace demonstratest the use of `markdown_check_links_test`.

NOTE: The links in this document are meant to be relative to this child workspace, not the parent
workspace. Hence, if you navigated here from the parent workspace, the absolute paths (i.e.,
starting with a `/`) will not work properly. However, they must remain as is for the integration
tests to work properly.

- [External Link](https://bazel.build/)
- [Internal Link, same package](/foo.md)
- [Link to bar package](/bar/)
