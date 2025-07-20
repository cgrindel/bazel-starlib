# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Overview

Bazel Starlib is a collection of projects containing rulesets and libraries for Bazel projects.
The repository is organized as a monorepo with multiple related Bazel projects:

- **bazeldoc**: Generate Starlark documentation using Bazel Stardoc
- **bzlformat**: Format Bazel Starlark files using Buildifier
- **bzllib**: Collection of Starlark libraries
- **bzlrelease**: Automate release generation using GitHub Actions
- **bzltidy**: Collect Bazel actions to keep source files up-to-date
- **markdown**: Maintain markdown files
- **shlib**: Shell libraries for implementing binaries, libraries, and tests
- **updatesrc**: Copy files from Bazel output directories to workspace

## Common Commands

### Development Workflow

```bash
# Quick source file updates (most common during development)
bazel run //:update_files

# Full tidy operation (runs formatting, updates source files)
bazel run //:tidy

# Format all code using rules_lint
bazel run //:format

# Update all generated source files
bazel run //:update_all

# Tidy all child workspaces
bazel run //:tidy_all

# Tidy only modified workspaces
bazel run //:tidy_modified
```

### Golang Dependencies

```bash
# Add a new Go dependency
bazel run @io_bazel_rules_go//go -- github.com/sweet/go_pkg

# Update go.mod and Bazel files
bazel run //:go_mod_tidy
bazel run //:gazelle_update_repos
bazel run //:update_build_files
```

### Formatting and Linting

```bash
# Format all source files
bazel run //:format

# Find missing bzlformat packages
bazel run //:bzlformat_missing_pkgs

# Fix missing bzlformat packages
bazel run //:bzlformat_missing_pkgs_fix
```

### Testing

```bash
# Run integration tests (smoke tests)
bazel test //:smoke_integration_tests

# Run all integration tests
bazel test //:all_integration_tests

# Run with CI configuration
bazel test --config=ci //...
```

### Build Configuration

```bash
# Build with remote cache
bazel build --config=cache //...

# Build without any caches
bazel build --config=no_cache //...
```

## Architecture

### Module Structure

Each project follows a consistent structure:

- `defs.bzl`: Public API exports
- `private/`: Internal implementation files
- `tools/`: Executable scripts and binaries
- `README.md`: Project-specific documentation

### Key Build Patterns

**Bzlmod Support**: The repository uses Bzlmod with `MODULE.bazel` as the primary dependency
management system, with legacy `WORKSPACE` support maintained.

**Integration Testing**: Extensive integration test infrastructure using
`rules_bazel_integration_test` with child workspaces in `/examples/` and `/tests/`.

**Code Generation**: Many projects generate documentation, build files, and other artifacts
that need to be kept in sync using the `updatesrc` system.

**Shell Library Pattern**: The `shlib` project provides reusable shell functions following a
library loading pattern with `cgrindel_bazel_shlib_lib_*_loaded()` functions.

### Toolchain Integration

- **Git Toolchain**: Custom git toolchain via `//tools/git`
- **Gazelle**: Automated BUILD file generation for Go code
- **Buildifier**: Starlark file formatting and linting
- **Stardoc**: Documentation generation for Starlark rules

### Configuration Files

- `shared.bazelrc`: Common Bazel configurations (bzlmod, caching, error reporting)
- `ci.bazelrc`: CI-specific settings (no color, detailed test output)
- `.bazelversion`: Specifies required Bazel version
- `go.mod`/`go.sum`: Go module dependencies for Go-based tools

## Development Notes

### File Organization

- `/doc/`: Generated API documentation for all projects
- `/examples/`: Example workspaces demonstrating usage
- `/tests/`: Integration and unit tests
- `/tools/`: Shared tooling (git, gh, tar, format)
- `/ci/`: CI workflow generation utilities

### Release Process

Releases are automated through GitHub Actions using the `bzlrelease` system, which:

- Generates release archives
- Updates README with workspace snippets
- Creates GitHub releases with proper versioning

### Shell Script Standards

All shell scripts follow these conventions:

- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -o errexit -o nounset -o pipefail`
- 2-space indentation
- Use `shfmt -i 2 -ci -bn` for formatting
