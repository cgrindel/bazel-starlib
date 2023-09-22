package mdtoc

import (
	"fmt"
	"strings"

	"github.com/gomarkdown/markdown/ast"
)

const indent = "  "

type Heading struct {
	Title string
	Level int
}

func NewHeadingFromNode(headingNode *ast.Heading) *Heading {
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
		Title: strings.Join(parts, " "),
		Level: headingNode.Level,
	}
}

func (h *Heading) String() string {
	indentCnt := h.Level - 1
	return strings.Repeat(indent, indentCnt) + h.Title
}
