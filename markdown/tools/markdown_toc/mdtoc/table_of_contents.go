package mdtoc

import (
	"fmt"
	"io"
	"strings"

	"github.com/gomarkdown/markdown/ast"
	"github.com/gomarkdown/markdown/parser"
)

const singleIndent = "  "

type MarkdownBullet = string

const (
	AsteriskMarkdownBullet MarkdownBullet = "*"
	HyphenMarkdownBullet   MarkdownBullet = "-"
)

type TableOfContents struct {
	Headings       []*Heading
	MarkdownBullet MarkdownBullet
}

func New() *TableOfContents {
	return &TableOfContents{
		Headings:       nil,
		MarkdownBullet: AsteriskMarkdownBullet,
	}
}

type TableOfContentsWithable = func(toc *TableOfContents)

func NewWith(withable TableOfContentsWithable) *TableOfContents {
	toc := New()
	withable(toc)
	return toc
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
	toc := New()
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
	return toc
}

func (toc *TableOfContents) Fprint(w io.Writer) (err error) {
	return toc.FprintAtStartLevel(w, 1)
}

func (toc *TableOfContents) FprintAtStartLevel(w io.Writer, startLevel int) (err error) {
	if startLevel < 1 {
		return fmt.Errorf("invalid start level: %d", startLevel)
	}
	for _, h := range toc.Headings {
		if h.Level < startLevel {
			continue
		}
		indentCnt := h.Level - startLevel
		indent := strings.Repeat(singleIndent, indentCnt)
		_, err := fmt.Fprintf(w, "%s%s %s\n", indent, toc.MarkdownBullet, h.MarkdownLink())
		if err != nil {
			return err
		}
	}
	return nil
}
