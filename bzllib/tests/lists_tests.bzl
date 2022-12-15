"""Tests for `lists` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bzllib/private:lists.bzl", "lists")

def _compact_test(ctx):
    env = unittest.begin(ctx)

    actual = lists.compact([])
    asserts.equals(env, [], actual)

    actual = lists.compact([None, None, None])
    asserts.equals(env, [], actual)

    actual = lists.compact(["zebra", None, "apple"])
    asserts.equals(env, ["zebra", "apple"], actual)

    return unittest.end(env)

compact_test = unittest.make(_compact_test)

def _contains_test(ctx):
    env = unittest.begin(ctx)

    actual = lists.contains([], "apple")
    asserts.false(env, actual)

    actual = lists.contains(["zebra"], "apple")
    asserts.false(env, actual)

    actual = lists.contains(["zebra", "apple"], "apple")
    asserts.true(env, actual)

    zebra = struct(name = "zebra")
    apple = struct(name = "apple")
    items = [zebra, apple]

    actual = lists.contains(items, lambda x: x.name == "zebra")
    asserts.true(env, actual)

    actual = lists.contains(items, lambda x: x.name == "apple")
    asserts.true(env, actual)

    actual = lists.contains(items, lambda x: x.name == "does_not_exist")
    asserts.false(env, actual)

    return unittest.end(env)

contains_test = unittest.make(_contains_test)

def _find_test(ctx):
    env = unittest.begin(ctx)

    zebra = struct(name = "zebra")
    apple = struct(name = "apple")
    items = [zebra, apple]

    actual = lists.find(items, lambda item: item.name == "does_not_exist")
    asserts.equals(env, None, actual)

    actual = lists.find(items, lambda item: item.name == "zebra")
    asserts.equals(env, zebra, actual)

    actual = lists.find(items, lambda item: item.name == "apple")
    asserts.equals(env, apple, actual)

    return unittest.end(env)

find_test = unittest.make(_find_test)

def lists_test_suite():
    return unittest.suite(
        "lists_tests",
        compact_test,
        contains_test,
        find_test,
    )
