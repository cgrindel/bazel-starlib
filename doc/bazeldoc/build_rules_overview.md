<!-- Generated with Stardoc, Do Not Edit! -->
# Build Rules

The macros described below are used to generate, test and copy 
Starlark documentation.

On this page:

  * [doc_for_provs](#doc_for_provs)
  * [stardoc_for_prov](#stardoc_for_prov)
  * [stardoc_for_provs](#stardoc_for_provs)
  * [write_doc](#write_doc)
  * [write_file_list](#write_file_list)
  * [write_header](#write_header)


<a id="doc_for_provs"></a>

## doc_for_provs

<pre>
doc_for_provs(<a href="#doc_for_provs-doc_provs">doc_provs</a>, <a href="#doc_for_provs-kwargs">kwargs</a>)
</pre>

Defines targets for generating documentation, testing that the generated doc matches the workspace directory, and copying the generated doc to the workspace directory.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="doc_for_provs-doc_provs"></a>doc_provs |  A `list` of document provider `struct` values as returned from `providers.create()`.   |  none |
| <a id="doc_for_provs-kwargs"></a>kwargs |  Common attributes that are applied to the underlying rules.   |  none |


<a id="write_file_list"></a>

## write_file_list

<pre>
write_file_list(<a href="#write_file_list-name">name</a>, <a href="#write_file_list-out">out</a>, <a href="#write_file_list-header_content">header_content</a>, <a href="#write_file_list-doc_provs">doc_provs</a>, <a href="#write_file_list-do_not_edit_warning">do_not_edit_warning</a>)
</pre>

Defines a target that writes a documentation file that contains a header and a list of files.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="write_file_list-name"></a>name |  The name of the target.   |  none |
| <a id="write_file_list-out"></a>out |  The basename of the output filename as a `string`.   |  none |
| <a id="write_file_list-header_content"></a>header_content |  A `list` of strings representing the header content of the file.   |  `[]` |
| <a id="write_file_list-doc_provs"></a>doc_provs |  A `list` of document provider `struct` values as returned from `providers.create()`.   |  `[]` |
| <a id="write_file_list-do_not_edit_warning"></a>do_not_edit_warning |  A `bool` specifying whether a comment should be added to the top of the written file.   |  `True` |

**RETURNS**

None.


<a id="write_header"></a>

## write_header

<pre>
write_header(<a href="#write_header-name">name</a>, <a href="#write_header-out">out</a>, <a href="#write_header-header_content">header_content</a>, <a href="#write_header-symbols">symbols</a>, <a href="#write_header-do_not_edit_warning">do_not_edit_warning</a>)
</pre>

Defines a target that writes a header file that will be used as a header template for a `stardoc` rule.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="write_header-name"></a>name |  The name of the target.   |  none |
| <a id="write_header-out"></a>out |  The basename of the output filename as a `string`.   |  `None` |
| <a id="write_header-header_content"></a>header_content |  A `list` of strings representing the header content of the file.   |  `[]` |
| <a id="write_header-symbols"></a>symbols |  A `list` of symbol names that will be included in the documentation.   |  `[]` |
| <a id="write_header-do_not_edit_warning"></a>do_not_edit_warning |  A `bool` specifying whether a comment should be added to the top of the written file.   |  `True` |

**RETURNS**

None.


