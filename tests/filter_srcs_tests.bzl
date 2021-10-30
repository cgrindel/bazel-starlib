load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _something_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

something_test = unittest.make(_something_test)

def filter_srcs_test_suite():
    return unittest.suite(
        "filter_srcs_tests",
        something_test,
    )
