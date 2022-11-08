# Golang Dependencies

The `bazel-starlib` repository uses Golang modules that contain exeutable packages (e.g., binaries).
To ensure that these binary targets are downloaded and built properly, a simple Golang program
exists to reference the required packages. [Gazelle](https://github.com/bazelbuild/bazel-gazelle) is
then used to identify the transitive dependencies and saves them to `go_deps.bzl`.

## To Add a Golang Dependency

Update the `main.go` in this directory to depend upon the desired Golang package. Be sure to use the
package in some way. Otherwise, `go mod tidy` will remove it.

Execute `//:tidy` to update the `go_deps.bzl` and ensure that the build files are updated properly.

```sh
$ go mod tidy
$ bazel run //:gazelle_update_repos
$ bazel run //:gazelle
```

Reference the Golang binary target.
