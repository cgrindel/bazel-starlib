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
			exp: mdtoc.NewWith(func(toc *mdtoc.TableOfContents) {
				toc.Headings = []*mdtoc.Heading{
					mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
						h.Title = "Foo Bar"
						h.Text = "Foo Bar"
					}),
				}
			}),
		},
		{
			msg: "Level 2 heading",
			in:  "## Foo Bar",
			exp: mdtoc.NewWith(func(toc *mdtoc.TableOfContents) {
				toc.Headings = []*mdtoc.Heading{
					mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
						h.Title = "Foo Bar"
						h.Text = "Foo Bar"
						h.Level = 2
					}),
				}
			}),
		},
		{
			msg: "Code in title",
			in:  "# `MODULE.bazel` Snippet",
			exp: mdtoc.NewWith(func(toc *mdtoc.TableOfContents) {
				toc.Headings = []*mdtoc.Heading{
					mdtoc.NewHeadingWith(func(h *mdtoc.Heading) {
						h.Title = "`MODULE.bazel` Snippet"
						h.Text = "MODULE.bazel Snippet"
					}),
				}
			}),
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
			bullet mdtoc.MarkdownBullet
			exp    string
			expErr error
		}{
			{
				msg:    "start at level 1",
				md:     multiLevelMarkdown,
				level:  1,
				bullet: mdtoc.HyphenMarkdownBullet,
				exp: `- [Heading 1](#heading-1)
  - [Heading 2a](#heading-2a)
    - [Heading 3](#heading-3)
  - [Heading 2b](#heading-2b)
`,
			},
			{
				msg:    "start at level 2",
				md:     multiLevelMarkdown,
				level:  2,
				bullet: mdtoc.HyphenMarkdownBullet,
				exp: `- [Heading 2a](#heading-2a)
  - [Heading 3](#heading-3)
- [Heading 2b](#heading-2b)
`,
			},
			{
				msg:    "start at level 3",
				md:     multiLevelMarkdown,
				level:  3,
				bullet: mdtoc.HyphenMarkdownBullet,
				exp: `- [Heading 3](#heading-3)
`,
			},
			{
				msg:    "start at level 4",
				md:     multiLevelMarkdown,
				level:  4,
				bullet: mdtoc.AsteriskMarkdownBullet,
				exp:    ``,
			},
			{
				msg:    "asteris bullet",
				md:     multiLevelMarkdown,
				level:  1,
				bullet: mdtoc.AsteriskMarkdownBullet,
				exp: `* [Heading 1](#heading-1)
  * [Heading 2a](#heading-2a)
    * [Heading 3](#heading-3)
  * [Heading 2b](#heading-2b)
`,
			},
			{
				msg:    "invalid level",
				md:     multiLevelMarkdown,
				level:  0,
				bullet: mdtoc.AsteriskMarkdownBullet,
				expErr: fmt.Errorf("invalid start level: 0"),
			},
		}
		for _, tt := range tests {
			var b bytes.Buffer
			toc := mdtoc.NewFromBytes([]byte(tt.md))
			toc.MarkdownBullet = tt.bullet
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
