package main

import (
	"flag"
	"io"
	"log"
	"os"

	"github.com/cgrindel/bazel-starlib/markdown/tools/markdown_toc/mdtoc"
	"github.com/gomarkdown/markdown/parser"
)

func main() {
	var outputPath string
	flag.StringVar(&outputPath, "output", "", "path for the TOC output")
	flag.Parse()

	inputPath := flag.Arg(0)
	var err error
	var input []byte
	if inputPath != "" {
		input, err = os.ReadFile(inputPath)
		if err != nil {
			log.Fatalf("Failed to read input file at %s.", inputPath)
		}
	} else {
		input, err = io.ReadAll(os.Stdin)
		if err != nil {
			log.Fatal("Failed to read input from stdin.")
		}
	}

	p := parser.New()
	doc := p.Parse(input)

	toc := mdtoc.NewFromAST(doc)
	// DEBUG BEGIN
	log.Printf("*** CHUCK:  toc.String():\n%s", toc.String())
	// DEBUG END

	// ast.WalkFunc(doc, func(node ast.Node, entering bool) ast.WalkStatus {
	// 	if !entering {
	// 		return ast.GoToNext
	// 	}
	// 	if headingNode, ok := node.(*ast.Heading); ok {
	// 		// DEBUG BEGIN
	// 		log.Printf("*** CHUCK: ==========")
	// 		log.Printf("*** CHUCK:  headingNode: %+#v", headingNode)
	// 		for _, childNode := range headingNode.Children {
	// 			if textNode, ok := childNode.(*ast.Text); ok {
	// 				log.Printf("*** CHUCK:  string(textNode.Literal)): %+#v", string(textNode.Literal))
	// 			}
	// 		}
	// 		// DEBUG END
	// 	}

	// 	return ast.GoToNext
	// 	// return renderer.RenderNode(&buf, node, entering)
	// })
}
