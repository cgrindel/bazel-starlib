<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to maintain markdown
files.

On this page:

  * [markdown_check_links_test](#markdown_check_links_test)
  * [markdown_generate_toc](#markdown_generate_toc)
  * [markdown_pkg](#markdown_pkg)
  * [markdown_register_node_deps](#markdown_register_node_deps)


<a id="#markdown_check_links_test"></a>

## markdown_check_links_test

<pre>
markdown_check_links_test(<a href="#markdown_check_links_test-name">name</a>, <a href="#markdown_check_links_test-config">config</a>, <a href="#markdown_check_links_test-data">data</a>, <a href="#markdown_check_links_test-max_econnreset_retry_count">max_econnreset_retry_count</a>, <a href="#markdown_check_links_test-quiet">quiet</a>, <a href="#markdown_check_links_test-srcs">srcs</a>, <a href="#markdown_check_links_test-verbose">verbose</a>)
</pre>

Using [`markdown-link-check`](https://github.com/tcort/markdown-link-check), check the links in a markdown file to ensure that they are valid.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="markdown_check_links_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="markdown_check_links_test-config"></a>config |  A <code>markdown-link-check</code> JSON configuration file.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @cgrindel_bazel_starlib//markdown:default_markdown_link_check_config |
| <a id="markdown_check_links_test-data"></a>data |  Any data files that need to be present for the link check to succeed.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="markdown_check_links_test-max_econnreset_retry_count"></a>max_econnreset_retry_count |  The maximum number of times to retry on an ECONNRESET error.   | Integer | optional | 3 |
| <a id="markdown_check_links_test-quiet"></a>quiet |  If set to true, the markdown-link-check will be configured to only display errors.   | Boolean | optional | True |
| <a id="markdown_check_links_test-srcs"></a>srcs |  The markdown files that should be checked. If no srcs are provided, all of the markdown files (.md, .markdown) in the <code>data</code> will be checked.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="markdown_check_links_test-verbose"></a>verbose |  If set to true, the markdown-link-check will be configured for verbose output.   | Boolean | optional | False |


<a id="#markdown_generate_toc"></a>

## markdown_generate_toc

<pre>
markdown_generate_toc(<a href="#markdown_generate_toc-name">name</a>, <a href="#markdown_generate_toc-output_suffix">output_suffix</a>, <a href="#markdown_generate_toc-remove_toc_header_entry">remove_toc_header_entry</a>, <a href="#markdown_generate_toc-srcs">srcs</a>, <a href="#markdown_generate_toc-toc_header">toc_header</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="markdown_generate_toc-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="markdown_generate_toc-output_suffix"></a>output_suffix |  The suffix added to the output file with the updated TOC.   | String | optional | ".toc_updated" |
| <a id="markdown_generate_toc-remove_toc_header_entry"></a>remove_toc_header_entry |  Specifies whether the header for the TOC should be removed from the TOC.   | Boolean | optional | True |
| <a id="markdown_generate_toc-srcs"></a>srcs |  The markdown files that will be updated with a table of contents.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="markdown_generate_toc-toc_header"></a>toc_header |  The header that leads the TOC.   | String | optional | "Table of Contents" |


<a id="#markdown_pkg"></a>

## markdown_pkg

<pre>
markdown_pkg(<a href="#markdown_pkg-name">name</a>, <a href="#markdown_pkg-srcs">srcs</a>, <a href="#markdown_pkg-toc_visibility">toc_visibility</a>, <a href="#markdown_pkg-update_visibility">update_visibility</a>, <a href="#markdown_pkg-define_doc_files">define_doc_files</a>, <a href="#markdown_pkg-doc_files_visibility">doc_files_visibility</a>,
             <a href="#markdown_pkg-additional_doc_files">additional_doc_files</a>)
</pre>

Adds targets to maintain markdown files in the package.

This macro adds targets to generate a table of contents (TOC) for markdown     files (`markdown_generate_toc`), adds `diff_test` targets to confirm that     the markdown files are up-to-date with the latest TOC, adds a target to     update the markdown files with the generated files (`updatesrc_update`)     and defines a `filegroup` that is useful to collecting documentation files     for confirming that a markdown files links are valid     (`markdown_check_links_test`)


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="markdown_pkg-name"></a>name |  A prefix <code>string</code> that will be added to all of the targets defined by this macro.   |  <code>"markdown"</code> |
| <a id="markdown_pkg-srcs"></a>srcs |  Optional. The markdown sources to be used by the macro. If none are specified, all of the <code>.md</code> and <code>.markdown</code> files are used.   |  <code>None</code> |
| <a id="markdown_pkg-toc_visibility"></a>toc_visibility |  Optional. The visibility for the TOC generation targets.   |  <code>None</code> |
| <a id="markdown_pkg-update_visibility"></a>update_visibility |  Optional. The visibility for the update target.   |  <code>None</code> |
| <a id="markdown_pkg-define_doc_files"></a>define_doc_files |  Optional. A <code>bool</code> that specifies whether to define a <code>filegroup</code> that can be used for documentation validity tests.   |  <code>True</code> |
| <a id="markdown_pkg-doc_files_visibility"></a>doc_files_visibility |  Optional. The visibility for the documentation <code>filegroup</code> target.   |  <code>["@//:__subpackages__"]</code> |
| <a id="markdown_pkg-additional_doc_files"></a>additional_doc_files |  Optional. Additional files that should be included in the documentation <code>filegroup</code>.   |  <code>[]</code> |


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


