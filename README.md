# Starlib

Starlib is a library of Starlark APIs and rules that are useful for the implementation of Bazel
projects, but do not exist in the [Skylib](https://github.com/bazelbuild/bazel-skylib) repository.

## Quickstart

The following provides a quick introduction on how to get started using the rules and APIs in this
repository. Check out [the documentation](/doc/) for more information.

### Workspace Configuration

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "cgrindel_bazel_starlib",
    sha256 = "1f5c6b13243a1a6f79742a8a0e883f7f4591f7890a388f87c8323f4242dc718d",
    strip_prefix = "bazel-starlib-0.1.0",
    urls = ["https://github.com/cgrindel/bazel-starlib/archive/v0.1.0.tar.gz"],
)

load("@cgrindel_bazel_starlib//:deps.bzl", "bazel_starlib_dependencies")

bazel_starlib_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@cgrindel_bazel_doc//bazeldoc:deps.bzl", "bazeldoc_dependencies")

bazeldoc_dependencies()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
```

