<!-- Generated with Stardoc, Do Not Edit! -->
# `src_utils` API


<a id="src_utils.is_label"></a>

## src_utils.is_label

<pre>
src_utils.is_label(<a href="#src_utils.is_label-src">src</a>)
</pre>

Determines whether the provided string is a label.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="src_utils.is_label-src"></a>src |  A `string` value.   |  none |

**RETURNS**

A `bool` specifying whether the `string` value looks like a label.


<a id="src_utils.is_path"></a>

## src_utils.is_path

<pre>
src_utils.is_path(<a href="#src_utils.is_path-src">src</a>)
</pre>

Determines whether the provided string is a path.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="src_utils.is_path-src"></a>src |  A `string` value.   |  none |

**RETURNS**

A `bool` specifying whether the `string` value looks like a path.


<a id="src_utils.path_to_name"></a>

## src_utils.path_to_name

<pre>
src_utils.path_to_name(<a href="#src_utils.path_to_name-path">path</a>, <a href="#src_utils.path_to_name-prefix">prefix</a>, <a href="#src_utils.path_to_name-suffix">suffix</a>)
</pre>

Converts a path string to a name suitable for use as a label name.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="src_utils.path_to_name-path"></a>path |  A path as a `string`.   |  none |
| <a id="src_utils.path_to_name-prefix"></a>prefix |  Optional. A string which will be prefixed to the namified path with an underscore separating the prefix.   |  `None` |
| <a id="src_utils.path_to_name-suffix"></a>suffix |  Optional. A `string` which will be appended to the namified path with an underscore separating the suffix.   |  `None` |

**RETURNS**

A `string` suitable for use as a label name.


