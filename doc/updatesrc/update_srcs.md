<!-- Generated with Stardoc, Do Not Edit! -->
# `update_srcs` API


<a id="update_srcs.create"></a>

## update_srcs.create

<pre>
load("@cgrindel_bazel_starlib//updatesrc:defs.bzl", "update_srcs")

update_srcs.create(<a href="#update_srcs.create-src">src</a>, <a href="#update_srcs.create-out">out</a>)
</pre>

Creates a `struct` specifying a source file and an output file that should be used to update it.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="update_srcs.create-src"></a>src |  A `File` designating a file in the workspace.   |  none |
| <a id="update_srcs.create-out"></a>out |  A `File` designating a file in the output directory.   |  none |

**RETURNS**

A `struct`.


