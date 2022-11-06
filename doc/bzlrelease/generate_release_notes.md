<!-- Generated with Stardoc, Do Not Edit! -->
# `generate_release_notes` Rule


<a id="generate_release_notes"></a>

## generate_release_notes

<pre>
generate_release_notes(<a href="#generate_release_notes-name">name</a>, <a href="#generate_release_notes-generate_workspace_snippet">generate_workspace_snippet</a>)
</pre>

Defines an executable target that generates release notes as Github markdown.

Typically, this macro is used in conjunction with the     `generate_workspace_snippet` macro. The `generate_workspace_snippet`     defines how to generate the workspace snippet. The resulting target     is then referenced by this macro.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="generate_release_notes-name"></a>name |  The name of the executable target as a <code>string</code>.   |  none |
| <a id="generate_release_notes-generate_workspace_snippet"></a>generate_workspace_snippet |  The label that should be executed to generate the workspace snippet.   |  none |


