"""Public API for bzltidy."""

load("//bzltidy/private:tidy.bzl", _tidy = "tidy")
load("//bzltidy/private:tidy_all.bzl", _tidy_all = "tidy_all")

tidy = _tidy
tidy_all = _tidy_all
