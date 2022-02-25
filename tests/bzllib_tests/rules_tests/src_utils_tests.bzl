"""Tests for src_utils Utilities"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bzllib:defs.bzl", "src_utils")

def _is_label_test(ctx):
    env = unittest.begin(ctx)

    asserts.true(env, src_utils.is_label("//Sources/Foo"))
    asserts.true(env, src_utils.is_label(":Foo"))
    asserts.true(env, src_utils.is_label("//Sources/Foo:bar"))
    asserts.false(env, src_utils.is_label("Bar.swift"))
    asserts.false(env, src_utils.is_label("path/to/Bar.swift"))

    return unittest.end(env)

is_label_test = unittest.make(_is_label_test)

def _is_path_test(ctx):
    env = unittest.begin(ctx)

    asserts.true(env, src_utils.is_path("Bar.swift"))
    asserts.true(env, src_utils.is_path("path/to/Bar.swift"))
    asserts.false(env, src_utils.is_path("//Sources/Foo"))
    asserts.false(env, src_utils.is_path(":Foo"))
    asserts.false(env, src_utils.is_path("//Sources/Foo:bar"))

    return unittest.end(env)

is_path_test = unittest.make(_is_path_test)

def _path_to_name_test(ctx):
    env = unittest.begin(ctx)

    actual = src_utils.path_to_name("chicken/foo.txt")
    asserts.equals(env, "chicken_foo_txt", actual, "Simple path.")
    actual = src_utils.path_to_name("chicken/foo.txt", prefix = "hello")
    asserts.equals(env, "hello_chicken_foo_txt", actual, "Path with prefix, no underscore.")
    actual = src_utils.path_to_name("chicken/foo.txt", prefix = "hello_")
    asserts.equals(env, "hello_chicken_foo_txt", actual, "Path with prefix, with underscore.")
    actual = src_utils.path_to_name("chicken/foo.txt", suffix = "goodbye")
    asserts.equals(env, "chicken_foo_txt_goodbye", actual, "Path with suffix, no underscore.")
    actual = src_utils.path_to_name("chicken/foo.txt", suffix = "_goodbye")
    asserts.equals(env, "chicken_foo_txt_goodbye", actual, "Path with suffix, with underscore.")

    return unittest.end(env)

path_to_name_test = unittest.make(_path_to_name_test)

def src_utils_test_suite():
    return unittest.suite(
        "src_utils_tests",
        is_label_test,
        is_path_test,
        path_to_name_test,
    )
