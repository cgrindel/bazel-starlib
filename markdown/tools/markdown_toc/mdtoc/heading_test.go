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
				h: &mdtoc.Heading{
					Title: "Other Configuration",
					Text:  "Other Configuration",
					Level: 1,
				},
				exp: "other-configuration",
			},
			{
				msg: "code in title",
				h: &mdtoc.Heading{
					Title: "`MODULE.bazel` Snippet",
					Text:  "MODULE.bazel Snippet",
					Level: 2,
				},
				exp: "modulebazel-snippet",
			},
		}
		for _, tt := range tests {
			actual := tt.h.AnchorID()
			assert.Equal(t, tt.exp, actual, tt.msg)
		}
	})

	t.Run("markdown link", func(t *testing.T) {
		heading := mdtoc.Heading{
			Title: "Other Configuration",
			Text:  "Other Configuration",
			Level: 1,
		}
		expected := "[Other Configuration](#other-configuration)"
		actual := heading.MarkdownLink()
		assert.Equal(t, expected, actual)
	})
}
