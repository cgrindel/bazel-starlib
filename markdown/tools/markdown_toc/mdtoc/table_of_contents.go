package mdtoc

import (
	"strings"

	"github.com/gomarkdown/markdown/ast"
)

type TableOfContents struct {
	Headings []*Heading
}

func NewFromAST(node ast.Node) *TableOfContents {
	var toc TableOfContents
	ast.WalkFunc(node, func(node ast.Node, entering bool) ast.WalkStatus {
		if !entering {
			return ast.GoToNext
		}
		if headingNode, ok := node.(*ast.Heading); ok {
			heading := NewHeadingFromNode(headingNode)
			toc.Headings = append(toc.Headings, heading)
			return ast.SkipChildren
		}
		return ast.GoToNext
	})
	return &toc
}

func (toc *TableOfContents) String() string {
	output := make([]string, len(toc.Headings))
	for idx, h := range toc.Headings {
		output[idx] = h.String()
	}
	return strings.Join(output, "\n")
}
