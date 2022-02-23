load(
    "//updatesrc/private:providers.bzl",
    _UpdateSrcsInfo = "UpdateSrcsInfo",
)
load(
    "//updatesrc/private:update_srcs.bzl",
    _update_srcs = "update_srcs",
)
load(
    "//updatesrc/private:updatesrc_diff_and_update.bzl",
    _updatesrc_diff_and_update = "updatesrc_diff_and_update",
)
load(
    "//updatesrc/private:updatesrc_update.bzl",
    _updatesrc_update = "updatesrc_update",
)
load(
    "//updatesrc/private:updatesrc_update_all.bzl",
    _updatesrc_update_all = "updatesrc_update_all",
)

# Providers
UpdateSrcsInfo = _UpdateSrcsInfo

# Rules and Macros
updatesrc_diff_and_update = _updatesrc_diff_and_update
updatesrc_update = _updatesrc_update
updatesrc_update_all = _updatesrc_update_all

# APIs
update_srcs = _update_srcs
