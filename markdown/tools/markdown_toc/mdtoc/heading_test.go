package mdtoc_test

import (
	"testing"

	"github.com/cgrindel/bazel-starlib/markdown/tools/markdown_toc/mdtoc"
	"github.com/stretchr/testify/assert"
)

func TestHeading(t *testing.T) {
	t.Run("anchor ID", func(t *testing.T) {
		tests := []struct {
			msg string
			h   *mdtoc.Heading
			exp string
		}{
			{
				msg: "simple",
				h: mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
					h.Title = "Other Configuration"
					h.Text = "Other Configuration"
				}),
				exp: "other-configuration",
			},
			{
				msg: "code in title",
				h: mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
					h.Title = "`MODULE.bazel` Snippet"
					h.Text = "MODULE.bazel Snippet"
				}),
				exp: "modulebazel-snippet",
			},
		}
		for _, tt := range tests {
			actual := tt.h.AnchorID()
			assert.Equal(t, tt.exp, actual, tt.msg)
		}
	})

	t.Run("markdown link", func(t *testing.T) {
		heading := mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
			h.Title = "Other Configuration"
			h.Text = "Other Configuration"
		})
		expected := "[Other Configuration](#other-configuration)"
		actual := heading.MarkdownLink()
		assert.Equal(t, expected, actual)
	})
}
