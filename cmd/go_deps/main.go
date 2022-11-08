package main

import (
	"fmt"
	"strings"

	gmt "github.com/ekalinin/github-markdown-toc.go"
)

func main() {
	fmt.Println("Hello, world.")

	ghtoc := generateToc()
	fmt.Printf("TOC:\n%s", ghtoc)
}

func generateToc() string {
	doc := &gmt.GHDoc{
		html: `
	<h1>
		<a id="user-content-readme-in-another-language" class="anchor" href="#readme-in-another-language" aria-hidden="true">
			<span class="octicon octicon-link"></span>
		</a>
		README in another language
	</h1>
	`, AbsPaths: false,
		Depth:  0,
		Escape: true,
		Indent: 2,
	}
	toc := *doc.GrabToc()
	return strings.Join(toc, "\n")
}
