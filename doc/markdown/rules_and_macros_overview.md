<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to maintain markdown
files.

On this page:

  * [markdown_check_links_test](#markdown_check_links_test)
  * [markdown_register_node_deps](#markdown_register_node_deps)


<a id="#markdown_check_links_test"></a>

## markdown_check_links_test

<pre>
markdown_check_links_test(<a href="#markdown_check_links_test-name">name</a>, <a href="#markdown_check_links_test-config">config</a>, <a href="#markdown_check_links_test-data">data</a>, <a href="#markdown_check_links_test-quiet">quiet</a>, <a href="#markdown_check_links_test-srcs">srcs</a>, <a href="#markdown_check_links_test-verbose">verbose</a>)
</pre>

Using [`markdown-link-check`](https://github.com/tcort/markdown-link-check), check the links in a markdown file to ensure that they are valid.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="markdown_check_links_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="markdown_check_links_test-config"></a>config |  A <code>markdown-link-check</code> JSON configuration file.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @cgrindel_bazel_starlib//markdown:default_markdown_link_check_config |
| <a id="markdown_check_links_test-data"></a>data |  Any data files that need to be present for the link check to succeed.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="markdown_check_links_test-quiet"></a>quiet |  If set to true, the markdown-link-check will be configured to only display errors.   | Boolean | optional | True |
| <a id="markdown_check_links_test-srcs"></a>srcs |  The markdown files that should be checked. If no srcs are provided, all of the markdown files (.md, .markdown) in the <code>data</code> will be checked.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="markdown_check_links_test-verbose"></a>verbose |  If set to true, the markdown-link-check will be configured for verbose output.   | Boolean | optional | False |


<a id="#markdown_register_node_deps"></a>

## markdown_register_node_deps

<pre>
markdown_register_node_deps(<a href="#markdown_register_node_deps-name">name</a>)
</pre>

Configures the installation of the Javascript node dependencies for the markdown functionality.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="markdown_register_node_deps-name"></a>name |  Optional. The name of the <code>yarn</code> repository that will be defined.   |  <code>"cgrindel_bazel_starlib_markdown_npm"</code> |


