load(":updatesrc_update.bzl", "updatesrc_update")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

# TODO: Add documentation

def updatesrc_update_and_test(
        srcs,
        outs,
        update_name = "update",
        diff_test_prefix = "",
        diff_test_suffix = "_difftest"):
    # Make sure that we have the same number of srcs and outs.
    if len(srcs) != len(outs):
        fail("The number of srcs does not match the number of outs.")

    # Define the update target
    updatesrc_update(
        name = update_name,
        srcs = srcs,
        outs = outs,
    )

    # Define the diff tests.
    for idx in range(len(srcs)):
        src = srcs[idx]
        out = outs[out]
        src_name = src.replace("/", "_")
        diff_test(
            name = diff_test_prefix + src_name + diff_test_suffix,
            file1 = src,
            file2 = out,
        )
