module github.com/cgrindel/bazel-starlib

go 1.19

require github.com/ekalinin/github-markdown-toc.go v0.0.0-20220910061337-2d4fdaaf52fa

require golang.org/x/net v0.1.0 // indirect

// The replace version is v0.0.0-<commit timestamp>-<first 12 characters of commit hash>
replace github.com/ekalinin/github-markdown-toc.go => github.com/cgrindel/github-markdown-toc.go v0.0.0-20220910061337-2d4fdaaf52fa
