"""Tests for `bazel_labels.new`."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

# buildifier: disable=bzl-visibility
load("//bzllib/private:bazel_labels.bzl", "make_bazel_labels")

# buildifier: disable=bzl-visibility
load(
    "//bzllib/private:workspace_name_resolvers.bzl",
    "make_stub_workspace_name_resolvers",
)

bazel_labels = make_bazel_labels(
    workspace_name_resolvers = make_stub_workspace_name_resolvers(
        repo_name = "@cool_repo",
        pkg_name = "Sources/Bar",
    ),
)

def _all_params_provied_test(ctx):
    env = unittest.begin(ctx)

    actual = bazel_labels.new(
        repository_name = "another_repo",
        package = "Sources/Foo",
        name = "chicken",
    )
    expected = struct(
        repository_name = "@another_repo",
        package = "Sources/Foo",
        name = "chicken",
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

all_params_provied_test = unittest.make(_all_params_provied_test)

def _package_and_name_provided_test(ctx):
    env = unittest.begin(ctx)

    actual = bazel_labels.new(
        package = "Sources/Foo",
        name = "chicken",
    )
    expected = struct(
        repository_name = "@cool_repo",
        package = "Sources/Foo",
        name = "chicken",
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

package_and_name_provided_test = unittest.make(_package_and_name_provided_test)

def _workspace_and_name_provided_test(ctx):
    env = unittest.begin(ctx)

    actual = bazel_labels.new(
        repository_name = "another_repo",
        name = "chicken",
    )
    expected = struct(
        repository_name = "@another_repo",
        package = "Sources/Bar",
        name = "chicken",
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

workspace_and_name_provided_test = unittest.make(_workspace_and_name_provided_test)

def _name_provided_test(ctx):
    env = unittest.begin(ctx)

    actual = bazel_labels.new(
        name = "chicken",
    )
    expected = struct(
        repository_name = "@cool_repo",
        package = "Sources/Bar",
        name = "chicken",
    )
    asserts.equals(env, expected, actual)

    return unittest.end(env)

name_provided_test = unittest.make(_name_provided_test)

def new_test_suite(name):
    return unittest.suite(
        name,
        all_params_provied_test,
        package_and_name_provided_test,
        workspace_and_name_provided_test,
        name_provided_test,
    )
