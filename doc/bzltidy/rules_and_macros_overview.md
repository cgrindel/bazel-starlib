<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to help keep your 
workspace source files up-to-date.

On this page:

  * [tidy](#tidy)


<a id="tidy"></a>

## tidy

<pre>
load("@cgrindel_bazel_starlib//bzltidy:defs.bzl", "tidy")

tidy(<a href="#tidy-name">name</a>, <a href="#tidy-targets">targets</a>)
</pre>

Defines targets for executing targets against the workspace and     confirming that there are no changes.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="tidy-name"></a>name |  The name of the target.   |  none |
| <a id="tidy-targets"></a>targets |  A `list` of targets to execute.   |  none |


