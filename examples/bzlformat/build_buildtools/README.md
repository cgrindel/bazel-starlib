# Build Buildtools from Source Example

Demonstrates how to use `bzlformat` building the
[bazelbuild/buildtools](https://github.com/bazelbuild/buildtools) from source.

## Overview

In the `WORKSPACE` file be sure to specify that you do not want to use the prebuilt tools.

```pytyhon
bazel_starlib_dependencies(use_prebuilt_buildtools = False)
```

Then, add the initialization code for the [buildtools](https://github.com/bazelbuild/buildtools).

```python
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.1")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()
```


