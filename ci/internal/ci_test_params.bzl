"""Module for creating test parameters."""

load(":providers.bzl", "CITestParamsInfo")

def _label_str(label):
    result = str(label)
    if result.startswith("@@"):
        pass
    elif result.startswith("@"):
        result = "@{}".format(result)
    else:
        result = "@@{}".format(result)
    return result

def _new_integration_test_params(test, os):
    return struct(
        test = _label_str(test),
        os = os,
    )

def _collect_from_deps(deps):
    itp_depsets = []
    for dep in deps:
        if CITestParamsInfo in dep:
            itp_depsets.append(dep[CITestParamsInfo].integration_test_params)
    return CITestParamsInfo(
        integration_test_params = depset([], transitive = itp_depsets),
    )

def _sort_integration_test_params(itps):
    return sorted(
        itps,
        key = lambda itp: "{test}_{os}".format(
            test = itp.test,
            os = itp.os,
        ),
    )

ci_test_params = struct(
    label_str = _label_str,
    new_integration_test_params = _new_integration_test_params,
    collect_from_deps = _collect_from_deps,
    sort_integration_test_params = _sort_integration_test_params,
)
