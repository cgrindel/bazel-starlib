<!-- Generated with Stardoc, Do Not Edit! -->
# `generate_workspace_snippet` Rule


<a id="#generate_workspace_snippet"></a>

## generate_workspace_snippet

<pre>
generate_workspace_snippet(<a href="#generate_workspace_snippet-name">name</a>, <a href="#generate_workspace_snippet-template">template</a>)
</pre>

Defines an executable target that generates a workspace snippet suitable     for inclusion in a markdown document.

Without a template, the utility will output an `http_archive` declaration.     With a template, the utility will output the template replacing     `${http_archive_statement}` with the `http_archive` declaration.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="generate_workspace_snippet-name"></a>name |  The name of the executable target as a <code>string</code>.   |  none |
| <a id="generate_workspace_snippet-template"></a>template |  The path to a template file  as a <code>string</code>.   |  <code>None</code> |


