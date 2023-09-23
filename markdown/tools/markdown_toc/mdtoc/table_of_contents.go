package mdtoc

import (
	"fmt"
	"io"
	"strings"

	"github.com/gomarkdown/markdown/ast"
	"github.com/gomarkdown/markdown/parser"
)

const singleIndent = "  "

type TableOfContents struct {
	Headings []*Heading
}

func NewFromBytes(b []byte) *TableOfContents {
	// Cannot use parser.AutoHeadingIDs as it does not format the heading IDs as
	// Commonmrker/comrak.
	extensions := parser.CommonExtensions | parser.AutoHeadingIDs
	p := parser.NewWithExtensions(extensions)
	doc := p.Parse(b)
	return newFromAST(doc)
}

func newFromAST(node ast.Node) *TableOfContents {
	var toc TableOfContents
	ast.WalkFunc(node, func(node ast.Node, entering bool) ast.WalkStatus {
		if !entering {
			return ast.GoToNext
		}
		if headingNode, ok := node.(*ast.Heading); ok {
			heading := newHeadingFromNode(headingNode)
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

func (toc *TableOfContents) FPrint(w io.Writer) (err error) {
	return toc.FPrintWithStart(w, 1)
}

func (toc *TableOfContents) FPrintWithStart(w io.Writer, startIndex int) (err error) {
	for _, h := range toc.Headings {
		if h.Level < startIndex {
			continue
		}
		indentCnt := h.Level - startIndex - 1
		indent := strings.Repeat(singleIndent, indentCnt)
		_, err := fmt.Fprintf(w, "%s- %s", indent, h.MarkdownLink())
		if err != nil {
			return err
		}
	}
	return nil
}
