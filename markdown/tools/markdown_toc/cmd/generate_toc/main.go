package main

import (
	"flag"
	"io"
	"log"
	"os"

	"github.com/cgrindel/bazel-starlib/markdown/tools/markdown_toc/mdtoc"
)

func main() {
	var outputPath string
	var startLevel int
	flag.StringVar(&outputPath, "output", "", "path for the TOC output")
	flag.IntVar(&startLevel, "start-level", 1, "starting heading level to render")
	flag.Parse()

	if startLevel < 1 {
		log.Fatalf("Invalid start index %d", startLevel)
	}

	inputPath := flag.Arg(0)
	var err error
	var input []byte
	if inputPath != "" {
		input, err = os.ReadFile(inputPath)
		if err != nil {
			log.Fatalf("Failed to read input file at %s.\n", inputPath)
		}
	} else {
		input, err = io.ReadAll(os.Stdin)
		if err != nil {
			log.Fatalln("Failed to read input from stdin.")
		}
	}
	var outW io.Writer
	if outputPath != "" {
		outFile, err := os.Create(outputPath)
		if err != nil {
			log.Fatalf("Failed opening output file %s; %s", outputPath, err)
		}
		defer outFile.Close()
		outW = outFile
	} else {
		outW = os.Stdout
	}

	toc := mdtoc.NewFromBytes(input)
	if err = toc.FPrintAtStartLevel(outW, startLevel); err != nil {
		log.Fatalf("Failed printing TOC; %s", err)
	}
}
