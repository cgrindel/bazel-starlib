<!-- Generated with Stardoc, Do Not Edit! -->
# `update_readme` Rule


<a id="update_readme"></a>

## update_readme

<pre>
update_readme(<a href="#update_readme-name">name</a>, <a href="#update_readme-generate_workspace_snippet">generate_workspace_snippet</a>, <a href="#update_readme-generate_module_snippet">generate_module_snippet</a>, <a href="#update_readme-readme">readme</a>)
</pre>

Declares an executable target that updates a README.md with an updated workspace snippet.

The utility will replace the lines between `&lt;!-- BEGIN WORKSPACE SNIPPET --&gt;` and     `&lt;!-- END WORKSPACE SNIPPET --&gt;` with the workspace snippet provided by the     `generate_workspace_snippet` utility that is provided.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="update_readme-name"></a>name |  The name of the executable target as a <code>string</code>.   |  none |
| <a id="update_readme-generate_workspace_snippet"></a>generate_workspace_snippet |  Optional. The label that should be executed to generate the workspace snippet.   |  <code>None</code> |
| <a id="update_readme-generate_module_snippet"></a>generate_module_snippet |  Optional. The label that should be executed to generate the Bazel module snippet.   |  <code>None</code> |
| <a id="update_readme-readme"></a>readme |  A <code>string</code> representing the relative path to the README.md file from the root of the workspace.   |  <code>None</code> |


