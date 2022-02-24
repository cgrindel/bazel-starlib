load(
    "//shlib/rules/private:execute_binary.bzl",
    _execute_binary = "execute_binary",
    _file_placeholder = "file_placeholder",
)
load(
    "//shlib/rules/private:execute_binary_utils.bzl",
    _execute_binary_utils = "execute_binary_utils",
)

execute_binary = _execute_binary
file_placeholder = _file_placeholder
execute_binary_utils = _execute_binary_utils
