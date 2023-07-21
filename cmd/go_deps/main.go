package main

import (
	"fmt"
	"strings"

	gmt "github.com/ekalinin/github-markdown-toc.go"
	"gopkg.in/alecthomas/kingpin.v2"
)

func main() {
	kingpin.Parse()
	fmt.Println("Hello, world.")

	ghtoc := generateToc()
	fmt.Printf("TOC:\n%s", ghtoc)
}

// Use the markdown package so that it is a dependency.
func generateToc() string {
	doc := gmt.NewGHDoc("", false, 0, 0, true, "", 2, false)
	toc := *doc.GrabToc()
	return strings.Join(toc, "\n")
}
