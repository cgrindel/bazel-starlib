load(":updatesrc_update.bzl", "updatesrc_update")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

# TODO: Add tests

def updatesrc_diff_and_update(
        srcs,
        outs,
        update_name = "update",
        diff_test_prefix = "",
        diff_test_suffix = "_difftest"):
    """Defines an `updatesrc_update` for the package and `diff_test` targets for each src-out pair.

    Args:
        srcs: Source files that will be updated by the files listed in the
              `outs` attribute.  Every file listed in the `srcs` attribute
              must have a corresponding output file listed in the `outs`
              attribute.
        outs: Output files that will be used to update the files listed in the
              `srcs` attribute. Every file listed in the `outs` attribute must
              have a corresponding source file list in the `srcs` attribute.
        update_name: Optional. The name of the `updatesrc_update` target.
        diff_test_prefix: Optional. The prefix to be used for the `diff_test`
                          target names.
        diff_test_suffix: Optional. The suffix to be used for the `diff_test`
                          target names.
    """

    # Make sure that we have the same number of srcs and outs.
    if len(srcs) != len(outs):
        fail("The number of srcs does not match the number of outs.")

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

    # Define the update target
    updatesrc_update(
        name = update_name,
        srcs = srcs,
        outs = outs,
    )
