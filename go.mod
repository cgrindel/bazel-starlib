module github.com/cgrindel/bazel-starlib

go 1.19

require github.com/ekalinin/github-markdown-toc.go v0.0.0-20220910061337-2d4fdaaf52fa

// replace github.com/ekalinin/github-markdown-toc.go v0.0.0-20220910061337-2d4fdaaf52fa => github.com/cgrindel/github-markdown-toc.go upgrade_to_go_1_19_1

// 563f2322eacc2fc3ea5be26d14c6f4d12076f87c
replace github.com/ekalinin/github-markdown-toc.go => github.com/cgrindel/github-markdown-toc.go v0.0.0-20221107201151-563f2322eacc
