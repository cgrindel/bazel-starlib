<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to update source files
from output files.

On this page:

  * [updatesrc_update](#updatesrc_update)
  * [updatesrc_update_all](#updatesrc_update_all)


<a id="#updatesrc_update"></a>

## updatesrc_update

<pre>
updatesrc_update(<a href="#updatesrc_update-name">name</a>, <a href="#updatesrc_update-deps">deps</a>, <a href="#updatesrc_update-outs">outs</a>, <a href="#updatesrc_update-srcs">srcs</a>)
</pre>

Updates the source files in the workspace directory using the specified output files.

There are two ways to specify the update mapping for this rule. 

Option #1: You can specify a list of source files and output files using the `srcs` and `outs` attributes, respectively. The source file at index 'n' in the `srcs` list will be updated by the output file at index 'n' in the `outs` list.

Option #2: Rules that provide `UpdateSrcsInfo` can be specified in the `deps` attribute.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="updatesrc_update-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="updatesrc_update-deps"></a>deps |  Build targets that output <code>UpdateSrcsInfo</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="updatesrc_update-outs"></a>outs |  Output files that will be used to update the files listed in the <code>srcs</code> attribute. Every file listed in the <code>outs</code> attribute must have a corresponding source file list in the <code>srcs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="updatesrc_update-srcs"></a>srcs |  Source files that will be updated by the files listed in the <code>outs</code> attribute. Every file listed in the <code>srcs</code> attribute must have a corresponding output file listed in the <code>outs</code> attribute.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |


<a id="#updatesrc_update_all"></a>

## updatesrc_update_all

<pre>
updatesrc_update_all(<a href="#updatesrc_update_all-name">name</a>, <a href="#updatesrc_update_all-targets_to_run">targets_to_run</a>)
</pre>

Defines a runnable target that will query for `updatesrc_update` targets and run them.

The utility queries for all of the `updatesrc_update` rules in the
workspace and executes each one. Hence, source files that are mapped
in these targets will be updated.

Additional targets to execute can be specified using the `targets_to_run`
attribute.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="updatesrc_update_all-name"></a>name |  The name of the target.   |  none |
| <a id="updatesrc_update_all-targets_to_run"></a>targets_to_run |  A <code>list</code> of labels to execute in addition to the <code>updatesrc_update</code> targets.   |  <code>[]</code> |

**RETURNS**

None.


