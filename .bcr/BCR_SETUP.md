# Bazel Central Registry (BCR) Publishing Setup

This repository uses the [publish-to-bcr](https://github.com/bazel-contrib/publish-to-bcr) GitHub
Actions workflow to automatically publish releases to the Bazel Central Registry.

## Current Setup

- **Workflow**: `.github/workflows/publish_to_bcr.yml`
- **Registry Fork**: `cgrindel/bazel-central-registry`
- **Module Name**: `cgrindel_bazel_starlib`
- **Trigger**: Automatically runs when a release is published
- **Manual Trigger**: Can be manually triggered via `workflow_dispatch` with a tag name

## Required Secret

- **BCR_PUBLISH_TOKEN**: A Classic GitHub Personal Access Token with `workflow` and `repo`
  permissions
  - Stored in repository secrets
  - Used to create pull requests in the registry fork

## How It Works

1. When a release is published, the workflow automatically triggers on the `release` event
2. The workflow gets the tag name directly from the release event (`github.event.release.tag_name`)
3. It calls the reusable `bazel-contrib/publish-to-bcr` workflow with:
   - The release tag name
   - The registry fork location
   - Attestation disabled
4. The workflow creates a pull request in `cgrindel/bazel-central-registry`
5. After reviewing and merging the PR in the fork, submit it to the upstream BCR

## Manual Publishing

To manually publish a release to BCR:

```bash
gh workflow run publish_to_bcr.yml -f tag_name=v1.2.3
```

## BCR Configuration Files

- `.bcr/config.yml` - Releaser information
- `.bcr/metadata.template.json` - Module metadata
- `.bcr/source.template.json` - Source configuration
- `.bcr/presubmit.yml` - BCR test module configuration

## Migration Notes

This setup replaces the deprecated "Publish to BCR" GitHub App, which stopped working as of the
last release. The new workflow-based approach is more maintainable and provides better control over
the publishing process.
