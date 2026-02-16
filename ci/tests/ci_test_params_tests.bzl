"""Tests for `ci_test_params` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//ci/internal:ci_test_params.bzl", "ci_test_params")
load("//ci/internal:providers.bzl", "CITestParamsInfo")

def _sort_integration_test_params_test(ctx):
    env = unittest.begin(ctx)

    itps = [
        ci_test_params.new_integration_test_params(
            test = "//:zebra",
            os = "macos",
        ),
        ci_test_params.new_integration_test_params(
            test = "//:zebra",
            os = "linux",
        ),
        ci_test_params.new_integration_test_params(
            test = "//:apple",
            os = "macos",
        ),
    ]
    expected = [
        ci_test_params.new_integration_test_params(
            test = "//:apple",
            os = "macos",
        ),
        ci_test_params.new_integration_test_params(
            test = "//:zebra",
            os = "linux",
        ),
        ci_test_params.new_integration_test_params(
            test = "//:zebra",
            os = "macos",
        ),
    ]
    actual = ci_test_params.sort_integration_test_params(itps)
    asserts.equals(env, expected, actual)

    return unittest.end(env)

sort_integration_test_params_test = unittest.make(_sort_integration_test_params_test)

def _collect_from_deps_test(ctx):
    env = unittest.begin(ctx)

    deps = [
        {CITestParamsInfo: CITestParamsInfo(
            integration_test_params = depset([
                ci_test_params.new_integration_test_params(
                    test = "//:zebra",
                    os = "macos",
                ),
            ]),
        )},
        {CITestParamsInfo: CITestParamsInfo(
            integration_test_params = depset([
                ci_test_params.new_integration_test_params(
                    test = "//:apple",
                    os = "linux",
                ),
            ]),
        )},
    ]
    actual = ci_test_params.collect_from_deps(deps)
    actual_itps = ci_test_params.sort_integration_test_params(
        actual.integration_test_params.to_list(),
    )
    expected_itps = [
        ci_test_params.new_integration_test_params(
            test = "//:apple",
            os = "linux",
        ),
        ci_test_params.new_integration_test_params(
            test = "//:zebra",
            os = "macos",
        ),
    ]
    asserts.equals(env, expected_itps, actual_itps)

    return unittest.end(env)

collect_from_deps_test = unittest.make(_collect_from_deps_test)

def _label_str_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "bzlmod label",
            inp = "@@//foo:bar",
            exp = "@@//foo:bar",
        ),
        struct(
            msg = "old-style label",
            inp = "@//foo:bar",
            exp = "@@//foo:bar",
        ),
        struct(
            msg = "no prefix",
            inp = "//foo:bar",
            exp = "@@//foo:bar",
        ),
    ]
    for t in tests:
        actual = ci_test_params.label_str(t.inp)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

label_str_test = unittest.make(_label_str_test)

def ci_test_params_test_suite(name = "ci_test_params_tests"):
    return unittest.suite(
        name,
        sort_integration_test_params_test,
        collect_from_deps_test,
        label_str_test,
    )
