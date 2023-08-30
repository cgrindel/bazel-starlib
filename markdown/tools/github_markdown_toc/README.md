# GitHub Markdown TOC

This utility is based upon [the gh-md-toc utility created by
eklanin](https://github.com/ekalinin/github-markdown-toc.go). The original implementation used
regular expressions to parse the HTML generated from GitHub's markdown rendering service.
Unfortunately, subtle changes in the output from this service can cause the regular expressions to
not work properly. I created [a pull request that replaced the regular experession logic with HTML
parsing using `golang.org/x/net/html`](https://github.com/ekalinin/github-markdown-toc.go/pull/38).
As of this writing, the pull request has not been merged.

After another outage due to the fragility of the regular expression logic on 2023-08-29, I opted to
fork the code with the HTML parsing logic and incorporate it into this repository. I preserved the
original license on the code. However, any changes to this utility may not be compatible with the
original code base.
