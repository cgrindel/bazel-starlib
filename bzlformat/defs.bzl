load(
    "//bzlformat/private:bzlformat_format.bzl",
    _bzlformat_format = "bzlformat_format",
)
load(
    "//bzlformat/private:bzlformat_pkg.bzl",
    _bzlformat_pkg = "bzlformat_pkg",
)
load(
    "//bzlformat/private:bzlformat_missing_pkgs.bzl",
    _bzlformat_missing_pkgs = "bzlformat_missing_pkgs",
)

bzlformat_format = _bzlformat_format
bzlformat_pkg = _bzlformat_pkg
bzlformat_missing_pkgs = _bzlformat_missing_pkgs
