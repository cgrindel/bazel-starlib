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
    "//bzlrelease/private:update_readme.bzl",
    _update_readme = "update_readme",
)

generate_workspace_snippet = _generate_workspace_snippet

generate_release_notes = _generate_release_notes

hash_sha256 = _hash_sha256

update_readme = _update_readme
