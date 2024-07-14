<!-- Generated with Stardoc, Do Not Edit! -->
# `providers` API


<a id="providers.create"></a>

## providers.create

<pre>
providers.create(<a href="#providers.create-name">name</a>, <a href="#providers.create-stardoc_input">stardoc_input</a>, <a href="#providers.create-deps">deps</a>, <a href="#providers.create-doc_label">doc_label</a>, <a href="#providers.create-out_basename">out_basename</a>, <a href="#providers.create-doc_basename">doc_basename</a>, <a href="#providers.create-header_label">header_label</a>,
                 <a href="#providers.create-header_basename">header_basename</a>, <a href="#providers.create-symbols">symbols</a>, <a href="#providers.create-is_stardoc">is_stardoc</a>)
</pre>

Create a documentation provider.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="providers.create-name"></a>name |  A `string` which identifies the doc output. If no `symbols` are provided, all of the symbols which are defined in the corresponding `.bzl` file are documented.   |  none |
| <a id="providers.create-stardoc_input"></a>stardoc_input |  A `string` representing the input label provided to the `stardoc` declaration.   |  none |
| <a id="providers.create-deps"></a>deps |  A `list` of deps for the stardoc rule.   |  none |
| <a id="providers.create-doc_label"></a>doc_label |  Optional. A `string` which is the doc label name.   |  `None` |
| <a id="providers.create-out_basename"></a>out_basename |  Optional. A `string` which is the basename for the output file.   |  `None` |
| <a id="providers.create-doc_basename"></a>doc_basename |  Optional. A `string` which is the basename for the final documentation file.   |  `None` |
| <a id="providers.create-header_label"></a>header_label |  Optional. A `string` which is the header label name, if the header is being generated.   |  `None` |
| <a id="providers.create-header_basename"></a>header_basename |  Optional. The basename (`string`) of the header filename file, if one is being used.   |  `None` |
| <a id="providers.create-symbols"></a>symbols |  Optional. A `list` of symbol names that should be included in the documentation.   |  `None` |
| <a id="providers.create-is_stardoc"></a>is_stardoc |  A `bool` indicating whether a `stardoc` declaration should be created.   |  `True` |

**RETURNS**

A `struct` representing a documentation provider.


