package mdtoc

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/gomarkdown/markdown/ast"
)

const indent = "  "

var anchorRejectedChars *regexp.Regexp

func init() {
	// https://github.com/kivikakk/comrak/blob/main/src/html.rs#L107-L111
	anchorRejectedChars = regexp.MustCompile(`\p{L}\p{M}\p{N}\p{Pc} -]`)
}

type Heading struct {
	Title string
	// Text  string // Title text without any modifiers
	Level int
}

func newHeadingFromNode(headingNode *ast.Heading) *Heading {
	var parts []string
	for _, childNode := range headingNode.Children {
		ast.WalkFunc(childNode, func(node ast.Node, entering bool) ast.WalkStatus {
			if !entering {
				return ast.GoToNext
			}
			switch tnode := node.(type) {
			case *ast.Text:
				parts = append(parts, string(tnode.Literal))
			case *ast.Code:
				content := fmt.Sprintf("`%s`", string(tnode.Literal))
				parts = append(parts, content)
			}

			return ast.GoToNext
		})
	}
	return &Heading{
		Title: strings.Join(parts, ""),
		Level: headingNode.Level,
	}
}

func (h *Heading) AnchorID() string {
	id := strings.ToLower(h.Title)
	id = anchorRejectedChars.ReplaceAllString(id, "")
	id = strings.ReplaceAll(id, " ", "-")
	return id
}

func (h *Heading) MarkdownLink() string {
	return fmt.Sprintf("[%s](#%s)", h.Title, h.AnchorID())
}

func (h *Heading) String() string {
	indentCnt := h.Level - 1
	return strings.Repeat(indent, indentCnt) + h.Title
}
