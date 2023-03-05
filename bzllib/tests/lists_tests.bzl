"""Tests for `lists` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//bzllib/private:lists.bzl", "lists")

def _compact_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            exp = [],
        ),
        struct(
            msg = "list of None",
            items = [None, None, None],
            exp = [],
        ),
        struct(
            msg = "list with None and other",
            items = ["zebra", None, "apple"],
            exp = ["zebra", "apple"],
        ),
        struct(
            msg = "list without None",
            items = ["zebra", "apple"],
            exp = ["zebra", "apple"],
        ),
    ]
    for t in tests:
        actual = lists.compact(t.items)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

compact_test = unittest.make(_compact_test)

def _contains_test(ctx):
    env = unittest.begin(ctx)

    zebra = struct(name = "zebra")
    apple = struct(name = "apple")
    structs = [zebra, apple]

    tests = [
        struct(
            msg = "empty list",
            items = [],
            target = "apple",
            exp = False,
        ),
        struct(
            msg = "list does not contain target",
            items = ["zebra"],
            target = "apple",
            exp = False,
        ),
        struct(
            msg = "list contains target",
            items = ["zebra", "apple"],
            target = "apple",
            exp = True,
        ),
        struct(
            msg = "list with bool fn, found target",
            items = structs,
            target = lambda x: x.name == "apple",
            exp = True,
        ),
        struct(
            msg = "list with bool fn, not found target",
            items = structs,
            target = lambda x: x.name == "does_not_exist",
            exp = False,
        ),
    ]
    for t in tests:
        actual = lists.contains(t.items, t.target)
        asserts.equals(env, t.exp, actual, t.msg)

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
