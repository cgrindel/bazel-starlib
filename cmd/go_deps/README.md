# Golang Dependencies

The `bazel-starlib` repository uses Golang modules that contain exeutable packages (e.g., binaries).
To ensure that these binary targets are downloaded and built properly, a simple Golang program
exists to reference the required packages. [Gazelle](https://github.com/bazelbuild/bazel-gazelle) is
then used to identify the transitive dependencies and saves them to `go_deps.bzl`.

NOTE: If the external Go module has dependencies that are referenced only in its `main` package, you
must update this repository to directly reference those direct dependencies. For instance,
`github.com/ekalinin/github-markdown-toc.go` references `gopkg.in/alecthomas/kingpin.v2` in its
`main` package. Hence, we added the version of `gopkg.in/alecthomas/kingpin.v2` that is referenced
in `github.com/ekalinin/github-markdown-toc.go` and added a usage to `cmd/go_deps`.

For more details, please see the following:

- https://github.com/bazelbuild/bazel-gazelle/issues/1585
- [Slack thread](https://bazelbuild.slack.com/archives/CDBP88Z0D/p1689814617770239)

## To Add a Golang Dependency

Update the `main.go` in this directory to depend upon the desired Golang package. Be sure to use the
package in some way. Otherwise, `go mod tidy` will remove it.

Execute the following to update the go module files, resolve the Golang dependencies and update the
Bazel build files.

```sh
$ bazel run @io_bazel_rules_go//go -- github.com/sweet/go_pkg
# bazel run //:go_mod_tidy
$ bazel run //:gazelle_update_repos
$ bazel run //:update_build_files
```

Reference the Golang binary target.
