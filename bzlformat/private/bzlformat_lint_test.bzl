"""Definition for bzlformat_lint_test rule."""

load("@aspect_bazel_lib//lib:windows_utils.bzl", "create_windows_native_launcher_script")
load("@bazel_skylib//lib:shell.bzl", "shell")
load("//shlib/rules:execute_binary.bzl", "execute_binary_utils")

def _bzlformat_lint_test_impl(ctx):
    bin_path = ctx.executable._buildifier.short_path
    common_arguments = ["--lint_mode", "warn", "--warnings", ctx.attr.warnings]

    # Generate the lint tests
    lint_tests = []
    for src in ctx.files.srcs:
        exec_binary_out = ctx.actions.declare_file(ctx.label.name + "_" + src.basename + ".sh")
        lint_tests.append(exec_binary_out)
        arguments = common_arguments + [src.short_path]
        execute_binary_utils.write_execute_binary_script(
            write_file = ctx.actions.write,
            out = exec_binary_out,
            bin_path = bin_path,
            arguments = arguments,
            workspace_name = ctx.workspace_name,
        )
    lint_test_names = [lt.short_path for lt in lint_tests]

    # Write a script that executes all of the lint tests
    bash_launcher = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = bash_launcher,
        is_executable = True,
        content = """\
#!/usr/bin/env bash

set -euo pipefail

""" + """\
lint_tests={lint_tests}
""".format(lint_tests = shell.array_literal(lint_test_names)) + """\

# Buildifier tries to find the workspace root. Since we are running in a
# sandbox, we need to provide a WORKSPACE file for it to find.
[[ ! -e WORKSPACE ]] && touch WORKSPACE

failure_count=0
for lint_test in "${lint_tests[@]}"; do
    exit_code=0
    "${lint_test}" || exit_code=$?
    if [[ ${exit_code} != 0 ]]; then
      failure_count=$(( ${failure_count} + 1 )) 
      echo >&2 "${lint_test} failed with ${exit_code}."
    fi
done

[[ ${failure_count} > 0 ]] && echo >&2 "${failure_count} lint tests failed." && exit 1
echo "All tests succeeded!"
""",
    )

    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])
    launcher = create_windows_native_launcher_script(ctx, bash_launcher) if is_windows else bash_launcher
    extra_runfiles = [bash_launcher] if is_windows else []

    # Gather the runfiles
    runfiles = ctx.runfiles(files = ctx.files.srcs + lint_tests + extra_runfiles)
    runfiles = execute_binary_utils.collect_runfiles(
        runfiles,
        [ctx.attr._buildifier],
    )

    # Return the DefaultInfo
    return DefaultInfo(executable = launcher, runfiles = runfiles)

bzlformat_lint_test = rule(
    implementation = _bzlformat_lint_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "The Starlark source files to lint.",
        ),
        "warnings": attr.string(
            doc = "The warnings that should be fixed if lint fix is enabled.",
            default = "all",
        ),
        "_buildifier": attr.label(
            default = "//bzlformat/tools:buildifier",
            executable = True,
            cfg = "exec",
            allow_files = True,
            doc = "The `buildifier` script that executes the formatting.",
        ),
        "_windows_constraint": attr.label(default = "@platforms//os:windows"),
    },
    toolchains = [
        "@bazel_tools//tools/sh:toolchain_type",
    ],
    doc = "Lints the specified Starlark files using Buildifier.",
)
