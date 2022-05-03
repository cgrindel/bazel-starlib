"""Set up the location for `bazelbuild/buildtools`"""

def _generate_trampoline_content(repository_ctx, filename, exec_location):
    content = """\
#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \\
  source "$0.runfiles/$f" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \\
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \\
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

""" + """\
executable_location={executable_location}
""".format(
        executable_location = exec_location,
    ) + """\
executable="$(rlocation "${executable_location}")" || \\
  (echo >&2 "Failed to locate ${executable_location}" && exit 1)

cmd=( "${executable}" )
[[ ${#} > 0 ]] && cmd+=( "${@}" )
"${cmd[@]}"
"""
    repository_ctx.file(filename, content, True)

def _bazel_starlib_buildtools_impl(repository_ctx):
    _generate_trampoline_content(
        repository_ctx,
        "buildifier.sh",
        repository_ctx.attr.buildifier_location,
    )
    _generate_trampoline_content(
        repository_ctx,
        "buildozer.sh",
        repository_ctx.attr.buildozer_location,
    )

    build_content = """\
package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "buildifier",
    srcs = ["buildifier.sh"],
    data = ["{buildifier}"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_binary(
    name = "buildozer",
    srcs = ["buildozer.sh"],
    data = ["{buildozer}"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
""".format(
        buildifier = repository_ctx.attr.buildifier_target,
        buildozer = repository_ctx.attr.buildozer_target,
    )
    repository_ctx.file("BUILD.bazel", build_content)

bazel_starlib_buildtools = repository_rule(
    implementation = _bazel_starlib_buildtools_impl,
    attrs = {
        "buildifier_location": attr.string(
            mandatory = True,
            doc = "The `buildifier` location in runfiles.",
        ),
        "buildifier_target": attr.string(
            mandatory = True,
            doc = "The `buildifier` target.",
        ),
        "buildozer_location": attr.string(
            mandatory = True,
            doc = "The `buildozer` target.",
        ),
        "buildozer_target": attr.string(
            mandatory = True,
            doc = "The `buildozer` target.",
        ),
    },
)
