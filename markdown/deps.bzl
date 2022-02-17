load("//markdown/private:github_markdown_toc_go_repositories.bzl", "github_markdown_toc_go_repositories")

def bazel_starlib_markdown_dependencies():
    # Deps for github-markdown-toc.go
    github_markdown_toc_go_repositories()
