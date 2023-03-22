#!/usr/bin/env bash

# --- begin runfiles.bash initialization v3 ---
# Copy-pasted from the Bazel Bash runfiles library v3.
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

# MARK - Locate Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

update_readme_sh_location=cgrindel_bazel_starlib/bzlrelease/tools/update_readme.sh
update_readme_sh="$(rlocation "${update_readme_sh_location}")" || \
  (echo >&2 "Failed to locate ${update_readme_sh_location}" && exit 1)


# MARK - Set up

export BUILD_WORKSPACE_DIRECTORY="${PWD}"

tag_name="v99999.0.0"

readme_content="$(cat <<-EOF
Text before workspace snippet
<!-- BEGIN WORKSPACE SNIPPET -->
Text should be replaced
<!-- END WORKSPACE SNIPPET -->
Text after workspace snippet
Text before module snippet
<!-- BEGIN MODULE SNIPPET -->
Text should be replaced
<!-- END MODULE SNIPPET -->
Text after module snippet
EOF
)"

generate_module_snippet_sh="${PWD}/generate_module_snippet.sh"
cat >"${generate_module_snippet_sh}" <<-EOF
#!/usr/bin/env bash
while (("\$#")); do
  case "\${1}" in
    "--version")
      version="\${2}"
      shift 2
      ;;
    "--output")
      output="\${2}"
      shift 2
      ;;
    *)
      echo >&2 "Unexpected arg. \${1}"
      exit 1
      ;;
  esac
done
if [[ -z "\${version:-}" ]]; then
  echo >&2 "Expected a version value."
  exit 1
fi
if [[ -z "\${output:-}" ]]; then
  echo >&2 "Expected a output value."
  exit 1
fi
echo "MODULE SNIPPET CONTENT" > "\${output}"
EOF
chmod +x "${generate_module_snippet_sh}"

generate_workspace_snippet_sh="${PWD}/generate_workspace_snippet.sh"
cat >"${generate_workspace_snippet_sh}" <<-EOF
#!/usr/bin/env bash
while (("\$#")); do
  case "\${1}" in
    "--tag")
      tag="\${2}"
      shift 2
      ;;
    "--output")
      output="\${2}"
      shift 2
      ;;
    *)
      echo >&2 "Unexpected arg. \${1}"
      exit 1
      ;;
  esac
done
if [[ -z "\${tag:-}" ]]; then
  echo >&2 "Expected a tag value."
  exit 1
fi
if [[ -z "\${output:-}" ]]; then
  echo >&2 "Expected a output value."
  exit 1
fi
echo "WORKSPACE SNIPPET CONTENT" > "\${output}"
EOF
chmod +x "${generate_workspace_snippet_sh}"

# MARK - Test Find README.md

readme_path="${BUILD_WORKSPACE_DIRECTORY}/README.md"

# Write README.md
echo "${readme_content}" > "${readme_path}"

"${update_readme_sh}" \
  --generate_workspace_snippet "${generate_workspace_snippet_sh}" \
  --generate_module_snippet "${generate_module_snippet_sh}" \
  "${tag_name}"

actual="$(< "${readme_path}")"
expected="$(cat <<-EOF
Text before workspace snippet
<!-- BEGIN WORKSPACE SNIPPET -->
WORKSPACE SNIPPET CONTENT
<!-- END WORKSPACE SNIPPET -->
Text after workspace snippet
Text before module snippet
<!-- BEGIN MODULE SNIPPET -->
MODULE SNIPPET CONTENT
<!-- END MODULE SNIPPET -->
Text after module snippet
EOF
)"
assert_equal "${expected}" "${actual}"
