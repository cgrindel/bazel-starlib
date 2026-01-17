# GitHub API Test Fixtures

This directory contains fixture files used for testing GitHub API interactions without making actual
API calls.

## Purpose

These fixtures allow tests to run in CI environments and offline without requiring GitHub API
access or authentication. They ensure tests are deterministic and fast by eliminating network
dependencies.

## Usage

Tests can use these fixtures by setting the `GH_CHANGELOG_MOCK_FILE` environment variable to the
path of a fixture file before calling GitHub changelog functions.

Example:

```bash
export GH_CHANGELOG_MOCK_FILE="${fixture_v0_1_0_v0_1_1}"
result="$(get_gh_changelog --tag_name "${tag_name}" --previous_tag_name "${prev_tag_name}")"
```

## Fixture Files

### changelog_v0.1.0_v0.1.1.txt

Simple changelog between v0.1.0 and v0.1.1 containing basic release notes with a few pull
requests.

### changelog_v0.24.0_v0.25.1.txt

Complex changelog between v0.24.0 and v0.25.1 containing multiple categories:

- Feature changes (feat:)
- Bug fixes (fix:)
- Chore updates (chore:)
- Dependency updates (chore(deps):, fix(deps):)

Used for testing the `get_gh_changelog_organized` function which categorizes changelog entries.

### changelog_v99999.0.0.txt

Minimal changelog for a future/nonexistent release. Used for testing edge cases and new tag
scenarios.

## Expected Format

All fixture files should match the format returned by the GitHub API endpoint:

```
POST /repos/{owner}/{repo}/releases/generate-notes
```

The response body should include:

- A "## What's Changed" header
- Bullet points with pull request links
- A "**Full Changelog**:" link at the bottom

Reference: [GitHub API
Documentation](https://docs.github.com/en/rest/releases/releases#generate-release-notes-content-for-a-release)

## Updating Fixtures

When the GitHub API response format changes or new test scenarios are needed:

1. Make an actual API call to get real response data (or check recent releases)
2. Copy the response body to a new or existing fixture file
3. Update the fixture filename to reflect the version range
4. Add the new fixture to `BUILD.bazel` in the `exports_files` list
5. Update test files to reference the new fixture using `rlocation`

## Implementation

The mock mechanism is implemented in `shlib/lib/github.sh` in the `get_gh_changelog` function. If
`GH_CHANGELOG_MOCK_FILE` is set and points to a valid file, the function returns the file contents
instead of making an API call.
