load("//rules:content_test.bzl", "content_test")
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")

def _something_test(ctx):
    env = unittest.begin(ctx)

    unittest.fail(env, "IMPLEMENT ME!")

    return unittest.end(env)

something_test = unittest.make(_something_test)

def content_test_test_suite():
    return unittest.suite(
        "content_test_tests",
        something_test,
    )
