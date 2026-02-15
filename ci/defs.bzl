"""Public API for CI workflow generation."""

load(
    "//ci/internal:ci_integration_test_params.bzl",
    _ci_integration_test_params = "ci_integration_test_params",
)
load(
    "//ci/internal:ci_test_params_suite.bzl",
    _ci_test_params_suite = "ci_test_params_suite",
)
load("//ci/internal:ci_workflow.bzl", _ci_workflow = "ci_workflow")
load(
    "//ci/internal:providers.bzl",
    _CITestParamsInfo = "CITestParamsInfo",
)

# Rules
ci_integration_test_params = _ci_integration_test_params
ci_workflow = _ci_workflow
ci_test_params_suite = _ci_test_params_suite

# Providers
CITestParamsInfo = _CITestParamsInfo
