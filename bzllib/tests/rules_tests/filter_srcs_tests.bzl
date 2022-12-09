"""Tests for filter_srcs Rule"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//bzllib:defs.bzl", "filter_srcs")

# MARK: - Set up inputs to the analysis tests.

def _setup_src_file_targets():
    write_file(
        name = "foo_a",
        out = "foo.a",
        content = ["This is foo.a"],
    )
    write_file(
        name = "foo_b",
        out = "foo.b",
        content = ["This is foo.b"],
    )
    write_file(
        name = "bar_a",
        out = "bar.a",
        content = ["This is bar.a"],
    )

# MARK: - Filename ends with test

def _filename_ends_with_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    results = [f.basename for f in target_under_test[DefaultInfo].files.to_list()]
    asserts.equals(env, ["foo.a", "bar.a"], results)

    return analysistest.end(env)

filename_ends_with_test = analysistest.make(_filename_ends_with_test_impl)

def _test_filename_ends_with():
    filter_srcs(
        name = "filename_ends_with_subject",
        srcs = [
            ":foo_a",
            ":foo_b",
            ":bar_a",
        ],
        filename_ends_with = ".a",
        tags = ["manual"],
    )
    filename_ends_with_test(
        name = "filename_ends_with_test",
        target_under_test = ":filename_ends_with_subject",
    )

# MARK: - Fail if no criteria test

def _fail_if_no_criteria_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "No filter criteria were provided.")

    return analysistest.end(env)

fail_if_no_criteria_test = analysistest.make(
    _fail_if_no_criteria_test_impl,
    expect_failure = True,
)

def _test_fail_if_no_criteria():
    filter_srcs(
        name = "fail_if_no_criteria_subject",
        srcs = [
            ":foo_a",
        ],
        tags = ["manual"],
    )
    fail_if_no_criteria_test(
        name = "fail_if_no_criteria_test",
        target_under_test = ":fail_if_no_criteria_subject",
    )

# MARK: - Expected Count Success Test

def _expected_count_success_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    results = [f.basename for f in target_under_test[DefaultInfo].files.to_list()]
    asserts.equals(env, ["foo.a", "bar.a"], results)

    return analysistest.end(env)

expected_count_success_test = analysistest.make(_expected_count_success_test_impl)

def _test_expected_count_success():
    filter_srcs(
        name = "expected_count_success_subject",
        srcs = [
            ":foo_a",
            ":foo_b",
            ":bar_a",
        ],
        filename_ends_with = ".a",
        expected_count = 2,
        tags = ["manual"],
    )
    expected_count_success_test(
        name = "expected_count_success_test",
        target_under_test = ":expected_count_success_subject",
    )

# MARK: - Expected Count Failure Test

def _expected_count_failure_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Expected 1 items, but found 2.")

    return analysistest.end(env)

expected_count_failure_test = analysistest.make(
    _expected_count_failure_test_impl,
    expect_failure = True,
)

def _test_expected_count_failure():
    filter_srcs(
        name = "expected_count_failure_subject",
        srcs = [
            ":foo_a",
            ":foo_b",
            ":bar_a",
        ],
        filename_ends_with = ".a",
        expected_count = 1,
        tags = ["manual"],
    )
    expected_count_failure_test(
        name = "expected_count_failure_test",
        target_under_test = ":expected_count_failure_subject",
    )

# MARK: - Test Suite

# buildifier: disable=unnamed-macro
def filter_srcs_test_suite():
    """Test Suite for filter_srcs tests"""
    _setup_src_file_targets()
    _test_filename_ends_with()
    _test_fail_if_no_criteria()
    _test_expected_count_success()
    _test_expected_count_failure()

    native.test_suite(
        name = "filter_srcs_tests",
        tests = [
            ":filename_ends_with_test",
            ":fail_if_no_criteria_test",
            ":expected_count_success_test",
            ":expected_count_failure_test",
        ],
    )
