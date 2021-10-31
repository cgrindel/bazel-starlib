load("//rules:filter_srcs.bzl", "filter_srcs")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

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

def _filename_ends_with_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    results = [f.basename for f in target_under_test[DefaultInfo].files.to_list()]
    asserts.equals(env, ["foo.a", "bar.a"], results)

    return analysistest.end(env)

filename_ends_with_test = analysistest.make(_filename_ends_with_test_impl)

def _test_filename_ends_with():
    # write_file(
    #     name = "foo_a",
    #     out = "foo.a",
    #     content = ["This is foo.a"],
    # )
    # write_file(
    #     name = "foo_b",
    #     out = "foo.b",
    #     content = ["This is foo.b"],
    # )
    # write_file(
    #     name = "bar_a",
    #     out = "bar.a",
    #     content = ["This is bar.a"],
    # )
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

def _fail_if_no_criteria_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "No filter criteria were provided.")

    return analysistest.end(env)

fail_if_no_criteria_test = analysistest.make(
    _fail_if_no_criteria_test_impl,
    expect_failure = True,
)

def _test_fail_if_no_criteria():
    # write_file(
    #     name = "foo_a",
    #     out = "foo.a",
    #     content = ["This is foo.a"],
    # )
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

def filter_srcs_test_suite():
    _setup_src_file_targets()
    _test_filename_ends_with()
    _test_fail_if_no_criteria()

    native.test_suite(
        name = "filter_srcs_tests",
        tests = [
            ":filename_ends_with_test",
            ":fail_if_no_criteria_test",
        ],
    )
