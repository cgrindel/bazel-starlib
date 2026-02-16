package testparams_test

import (
	"testing"

	"github.com/cgrindel/bazel-starlib/ci/tools/generate_ci_workflow/internal/testparams"
	"github.com/stretchr/testify/assert"
)

func TestNewIntTestParamsFromJSON(t *testing.T) {
	actual, err := testparams.NewIntTestParamsFromJSON([]byte(intTestParamsJSON))
	assert.NoError(t, err)
	assert.Len(t, actual, 2)
	expected := []testparams.IntTestParams{
		{Test: "@@//path:int_test", OS: "macos"},
		{Test: "@@//path:int_test", OS: "linux"},
	}
	assert.Equal(t, expected, actual)
}

const intTestParamsJSON = `
[
  {"test": "@@//path:int_test", "os": "macos"},
  {"test": "@@//path:int_test", "os": "linux"}
]
`
