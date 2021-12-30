<!-- Generated with Stardoc, Do Not Edit! -->
# `providers` API


<a id="#providers.create"></a>

## providers.create

<pre>
providers.create(<a href="#providers.create-name">name</a>, <a href="#providers.create-stardoc_input">stardoc_input</a>, <a href="#providers.create-deps">deps</a>, <a href="#providers.create-doc_label">doc_label</a>, <a href="#providers.create-out_basename">out_basename</a>, <a href="#providers.create-doc_basename">doc_basename</a>, <a href="#providers.create-header_label">header_label</a>,
                 <a href="#providers.create-header_basename">header_basename</a>, <a href="#providers.create-symbols">symbols</a>, <a href="#providers.create-is_stardoc">is_stardoc</a>)
</pre>

Create a documentation provider.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="providers.create-name"></a>name |  A <code>string</code> which identifies the doc output. If no <code>symbols</code> are provided, all of the symbols which are defined in the corresponding <code>.bzl</code> file are documented.   |  none |
| <a id="providers.create-stardoc_input"></a>stardoc_input |  A <code>string</code> representing the input label provided to the <code>stardoc</code> declaration.   |  none |
| <a id="providers.create-deps"></a>deps |  A <code>list</code> of deps for the stardoc rule.   |  none |
| <a id="providers.create-doc_label"></a>doc_label |  Optional. A <code>string</code> which is the doc label name.   |  <code>None</code> |
| <a id="providers.create-out_basename"></a>out_basename |  Optional. A <code>string</code> which is the basename for the output file.   |  <code>None</code> |
| <a id="providers.create-doc_basename"></a>doc_basename |  Optional. A <code>string</code> which is the basename for the final documentation file.   |  <code>None</code> |
| <a id="providers.create-header_label"></a>header_label |  Optional. A <code>string</code> which is the header label name, if the header is being generated.   |  <code>None</code> |
| <a id="providers.create-header_basename"></a>header_basename |  Optional. The basename (<code>string</code>) of the header filename file, if one is being used.   |  <code>None</code> |
| <a id="providers.create-symbols"></a>symbols |  Optional. A <code>list</code> of symbol names that should be included in the documentation.   |  <code>None</code> |
| <a id="providers.create-is_stardoc"></a>is_stardoc |  A <code>bool</code> indicating whether a <code>stardoc</code> declaration should be created.   |  <code>True</code> |

**RETURNS**

A `struct` representing a documentation provider.


