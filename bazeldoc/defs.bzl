load("//bazeldoc/private:doc_for_provs.bzl", _doc_for_provs = "doc_for_provs")
load("//bazeldoc/private:providers.bzl", _providers = "providers")
load("//bazeldoc/private:write_file_list.bzl", _write_file_list = "write_file_list")
load("//bazeldoc/private:write_header.bzl", _write_header = "write_header")

# Rules and Macros
doc_for_provs = _doc_for_provs
write_header = _write_header
write_file_list = _write_file_list

# API
providers = _providers
