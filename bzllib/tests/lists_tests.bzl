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

def _flatten_test(ctx):
    env = unittest.begin(ctx)

    actual = lists.flatten("foo")
    expected = ["foo"]
    asserts.equals(env, expected, actual)

    actual = lists.flatten(["foo"])
    expected = ["foo"]
    asserts.equals(env, expected, actual)

    actual = lists.flatten(["foo", ["alpha", ["omega"]], ["chicken", "cow"]])
    expected = ["foo", "alpha", "omega", "chicken", "cow"]
    asserts.equals(env, expected, actual)

    return unittest.end(env)

flatten_test = unittest.make(_flatten_test)

def _filter_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            fn = lambda x: x > 0,
            exp = [],
        ),
        struct(
            msg = "some matching values",
            items = [0, 4, 3, 0],
            fn = lambda x: x > 0,
            exp = [4, 3],
        ),
    ]
    for t in tests:
        actual = lists.filter(t.items, t.fn)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

filter_test = unittest.make(_filter_test)

def _map_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            fn = lambda x: x + 1,
            exp = [],
        ),
        struct(
            msg = "non-empty list",
            items = [-1, 0, 6, 3],
            fn = lambda x: x + 1,
            exp = [0, 1, 7, 4],
        ),
    ]
    for t in tests:
        actual = lists.map(t.items, t.fn)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

map_test = unittest.make(_map_test)

def lists_test_suite():
    return unittest.suite(
        "lists_tests",
        compact_test,
        contains_test,
        find_test,
        flatten_test,
        filter_test,
        map_test,
    )
