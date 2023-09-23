package mdtoc_test

import (
	"bytes"
	"fmt"
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
					{Title: "Foo Bar", Text: "Foo Bar", Level: 1},
				},
			},
		},
		{
			msg: "Level 2 heading",
			in:  "## Foo Bar",
			exp: &mdtoc.TableOfContents{
				Headings: []*mdtoc.Heading{
					{Title: "Foo Bar", Text: "Foo Bar", Level: 2},
				},
			},
		},
		{
			msg: "Code in title",
			in:  "## `MODULE.bazel` Snippet",
			exp: &mdtoc.TableOfContents{
				Headings: []*mdtoc.Heading{
					{
						Title: "`MODULE.bazel` Snippet",
						Text:  "MODULE.bazel Snippet",
						Level: 2,
					},
				},
			},
		},
	}
	for _, tt := range tests {
		actual := mdtoc.NewFromBytes([]byte(tt.in))
		assert.Equal(t, tt.exp, actual, tt.msg)
	}
}

const multiLevelMarkdown = `
# Heading 1

Some text

## Heading 2a

More Text

### Heading 3

## Heading 2b
`

func TestTableOfContents(t *testing.T) {
	t.Run("print at start level", func(t *testing.T) {
		tests := []struct {
			msg    string
			md     string
			level  int
			exp    string
			expErr error
		}{
			{
				msg:   "start at level 1",
				md:    multiLevelMarkdown,
				level: 1,
				exp: `- [Heading 1](#heading-1)
  - [Heading 2a](#heading-2a)
    - [Heading 3](#heading-3)
  - [Heading 2b](#heading-2b)
`,
			},
			{
				msg:   "start at level 2",
				md:    multiLevelMarkdown,
				level: 2,
				exp: `- [Heading 2a](#heading-2a)
  - [Heading 3](#heading-3)
- [Heading 2b](#heading-2b)
`,
			},
			{
				msg:   "start at level 3",
				md:    multiLevelMarkdown,
				level: 3,
				exp: `- [Heading 3](#heading-3)
`,
			},
			{
				msg:   "start at level 4",
				md:    multiLevelMarkdown,
				level: 4,
				exp:   ``,
			},
			{
				msg:    "invalid level",
				md:     multiLevelMarkdown,
				level:  0,
				expErr: fmt.Errorf("invalid start level: 0"),
			},
		}
		for _, tt := range tests {
			var b bytes.Buffer
			toc := mdtoc.NewFromBytes([]byte(tt.md))
			err := toc.FprintAtStartLevel(&b, tt.level)
			if tt.expErr == nil {
				assert.NoError(t, err)
				actual := b.String()
				assert.Equal(t, tt.exp, actual, tt.msg)
			} else {
				assert.Equal(t, tt.expErr, err)
			}
		}
	})
}
