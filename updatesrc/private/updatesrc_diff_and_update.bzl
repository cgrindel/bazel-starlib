"""Definition for updatesrc_diff_and_update macro."""

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load(":updatesrc_update.bzl", "updatesrc_update")

def updatesrc_diff_and_update(
        srcs,
        outs,
        name = None,
        update_name = "update",
        diff_test_prefix = "",
        diff_test_suffix = "_difftest",
        update_visibility = None,
        diff_test_visibility = None,
        failure_message = None,
        **kwargs):
    """Defines an `updatesrc_update` for the package and `diff_test` targets for each src-out pair.

    Args:
        srcs: Source files that will be updated by the files listed in the
              `outs` attribute.  Every file listed in the `srcs` attribute
              must have a corresponding output file listed in the `outs`
              attribute.
        outs: Output files that will be used to update the files listed in the
              `srcs` attribute. Every file listed in the `outs` attribute must
              have a corresponding source file list in the `srcs` attribute.
        name: Optional. The name of the `updatesrc_update` target.
        update_name: Deprecated. The name of the `updatesrc_update` target.
        diff_test_prefix: Optional. The prefix to be used for the `diff_test`
                          target names.
        diff_test_suffix: Optional. The suffix to be used for the `diff_test`
                          target names.
        update_visibility: Optional. The visibility declarations for the
                           `updatesrc_update` target.
        diff_test_visibility: Optional. The visibility declarations for the
                              `diff_test` targets.
        failure_message: Additional message to log if the files' contents do not match.
        **kwargs: Common attributes that are applied to the underlying rules.
    """

    # Apply the common visibility if another value was not already specified
    common_visibility = kwargs.pop("visibility", None)
    if common_visibility != None:
        if update_visibility == None:
            update_visibility = common_visibility
        if diff_test_visibility == None:
            diff_test_visibility = common_visibility

    # Make sure that we have the same number of srcs and outs.
    if len(srcs) != len(outs):
        fail("The number of srcs does not match the number of outs.")

    if name == None:
        if update_name == None:
            fail("Please specify a value for the name attribute.")
        else:
            name = update_name

    msg = failure_message

    # Define the diff tests.
    for idx in range(len(srcs)):
        src = srcs[idx]
        out = outs[idx]
        src_name = src.replace("/", "_")

        if failure_message == None:
            # create a helpful message if none has been given
            msg = "Run 'bazel run {}' to update {}".format(name, src)

        # this difftest fails as file2 has CRLf on windows
        # fix: https://github.com/bazelbuild/bazel-skylib/pull/527
        diff_test(
            name = diff_test_prefix + src_name + diff_test_suffix,
            file1 = src,
            file2 = out,
            visibility = diff_test_visibility,
            failure_message = msg,
            **kwargs
        )

    # Define the update target
    updatesrc_update(
        name = name,
        srcs = srcs,
        outs = outs,
        visibility = update_visibility,
        **kwargs
    )
