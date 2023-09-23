package mdtoc_test

import (
	"testing"

	"github.com/cgrindel/bazel-starlib/markdown/tools/markdown_toc/mdtoc"
	"github.com/stretchr/testify/assert"
)

func TestNewFromBytes(t *testing.T) {
	tests := []struct {
		msg string
		in  string
		exp *mdtoc.TableOfContents
	}{
		{
			msg: "Level 1 heading",
			in:  "# Foo Bar",
			exp: &mdtoc.TableOfContents{
				Headings: []*mdtoc.Heading{
					{Title: "Foo Bar", Level: 1},
				},
			},
		},
		{
			msg: "Level 2 heading",
			in:  "## Foo Bar",
			exp: &mdtoc.TableOfContents{
				Headings: []*mdtoc.Heading{
					{Title: "Foo Bar", Level: 2},
				},
			},
		},
		{
			msg: "Code in title",
			in:  "## `MODULE.bazel` Snippet",
			exp: &mdtoc.TableOfContents{
				Headings: []*mdtoc.Heading{
					{Title: "`MODULE.bazel` Snippet", Level: 2},
				},
			},
		},
	}
	for _, tt := range tests {
		actual := mdtoc.NewFromBytes([]byte(tt.in))
		assert.Equal(t, tt.exp, actual, tt.msg)
	}
}
