<!-- Generated with Stardoc, Do Not Edit! -->
# Providers

The providers described below are used by [the rules](/doc/updatesrc/rules_and_macros_overview.md) to
pass along information about the source files to be updated.

On this page:

  * [UpdateSrcsInfo](#UpdateSrcsInfo)


<a id="UpdateSrcsInfo"></a>

## UpdateSrcsInfo

<pre>
load("@cgrindel_bazel_starlib//updatesrc:defs.bzl", "UpdateSrcsInfo")

UpdateSrcsInfo(<a href="#UpdateSrcsInfo-update_srcs">update_srcs</a>)
</pre>

Information about files that should be copied from the output to the workspace.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="UpdateSrcsInfo-update_srcs"></a>update_srcs |  A `depset` of structs as created by `update_srcs.create()` which specify the source files and their outputs.    |


