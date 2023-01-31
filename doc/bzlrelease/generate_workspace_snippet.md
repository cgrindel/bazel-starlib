<!-- Generated with Stardoc, Do Not Edit! -->
# `generate_workspace_snippet` Rule


<a id="generate_workspace_snippet"></a>

## generate_workspace_snippet

<pre>
generate_workspace_snippet(<a href="#generate_workspace_snippet-name">name</a>, <a href="#generate_workspace_snippet-template">template</a>, <a href="#generate_workspace_snippet-workspace_name">workspace_name</a>, <a href="#generate_workspace_snippet-sha256_file">sha256_file</a>, <a href="#generate_workspace_snippet-url_templates">url_templates</a>)
</pre>

Defines an executable target that generates a workspace snippet suitable     for inclusion in a markdown document.

Without a template, the utility will output an `http_archive` declaration.     With a template, the utility will output the template replacing     `${http_archive_statement}` with the `http_archive` declaration.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="generate_workspace_snippet-name"></a>name |  The name of the executable target as a <code>string</code>.   |  none |
| <a id="generate_workspace_snippet-template"></a>template |  Optional. The path to a template file  as a <code>string</code>.   |  <code>None</code> |
| <a id="generate_workspace_snippet-workspace_name"></a>workspace_name |  Optional. The name of the workspace. If not provided, the workspace name is derived from the owner and repository name.   |  <code>None</code> |
| <a id="generate_workspace_snippet-sha256_file"></a>sha256_file |  Optional. The path to a file with the SHA256 value for the release archive.   |  <code>None</code> |
| <a id="generate_workspace_snippet-url_templates"></a>url_templates |  Optional. A <code>list</code> of templates to use when generating the URL values for the release archive.   |  <code>[]</code> |


