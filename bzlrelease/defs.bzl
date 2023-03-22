"""Public API for bzlrelease."""

load(
    "//bzlrelease/private:create_release.bzl",
    _create_release = "create_release",
)
load(
    "//bzlrelease/private:generate_module_snippet.bzl",
    _generate_module_snippet = "generate_module_snippet",
)
load(
    "//bzlrelease/private:generate_release_notes.bzl",
    _generate_release_notes = "generate_release_notes",
)
load(
    "//bzlrelease/private:generate_workspace_snippet.bzl",
    _generate_workspace_snippet = "generate_workspace_snippet",
)
load("//bzlrelease/private:hash_sha256.bzl", _hash_sha256 = "hash_sha256")
load(
    "//bzlrelease/private:release_archive.bzl",
    _release_archive = "release_archive",
)
load(
    "//bzlrelease/private:update_readme.bzl",
    _update_readme = "update_readme",
)

create_release = _create_release
generate_module_snippet = _generate_module_snippet
generate_release_notes = _generate_release_notes
generate_workspace_snippet = _generate_workspace_snippet
hash_sha256 = _hash_sha256
release_archive = _release_archive
update_readme = _update_readme
