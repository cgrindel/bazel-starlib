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
	// Duplicate what Commonmark (Ruby wrapper for comrak) does.
	// https://github.com/kivikakk/comrak/blob/main/src/html.rs#L107-L111
	anchorRejectedChars = regexp.MustCompile(`[^\p{L}\p{M}\p{N}\p{Pc} -]`)
}

type Heading struct {
	Title string
	Text  string // Title text without any modifiers
	Level int
}

func newHeadingFromNode(headingNode *ast.Heading) *Heading {
	var titleParts []string
	var textParts []string
	for _, childNode := range headingNode.Children {
		ast.WalkFunc(childNode, func(node ast.Node, entering bool) ast.WalkStatus {
			if !entering {
				return ast.GoToNext
			}
			switch tnode := node.(type) {
			case *ast.Text:
				literal := string(tnode.Literal)
				titleParts = append(titleParts, literal)
				textParts = append(textParts, literal)
			case *ast.Code:
				literal := string(tnode.Literal)
				title := fmt.Sprintf("`%s`", string(literal))
				titleParts = append(titleParts, title)
				textParts = append(textParts, literal)
			}

			return ast.GoToNext
		})
	}
	return &Heading{
		Title: strings.Join(titleParts, ""),
		Text:  strings.Join(textParts, ""),
		Level: headingNode.Level,
	}
}

func (h *Heading) AnchorID() string {
	id := strings.ToLower(h.Text)
	id = anchorRejectedChars.ReplaceAllString(id, "")
	id = strings.ReplaceAll(id, " ", "-")
	return id
}

func (h *Heading) MarkdownLink() string {
	return fmt.Sprintf("[%s](#%s)", h.Title, h.AnchorID())
}
