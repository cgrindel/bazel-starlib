<!-- Generated with Stardoc, Do Not Edit! -->
# `bazel_labels` API


<a id="bazel_labels.new"></a>

## bazel_labels.new

<pre>
bazel_labels.new(<a href="#bazel_labels.new-name">name</a>, <a href="#bazel_labels.new-repository_name">repository_name</a>, <a href="#bazel_labels.new-package">package</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_labels.new-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="bazel_labels.new-repository_name"></a>repository_name |  <p align="center"> - </p>   |  `None` |
| <a id="bazel_labels.new-package"></a>package |  <p align="center"> - </p>   |  `None` |


<a id="bazel_labels.normalize"></a>

## bazel_labels.normalize

<pre>
bazel_labels.normalize(<a href="#bazel_labels.normalize-value">value</a>)
</pre>

Converts a value into a Bazel label string.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_labels.normalize-value"></a>value |  A `Label`, `struct` from `bazel_labels.new`, or a `string`.   |  none |

**RETURNS**

A fully-formed Bazel label string.


<a id="bazel_labels.parse"></a>

## bazel_labels.parse

<pre>
bazel_labels.parse(<a href="#bazel_labels.parse-value">value</a>)
</pre>

Parse a string as a Bazel label returning its parts.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bazel_labels.parse-value"></a>value |  A `string` value to parse.   |  none |

**RETURNS**

A `struct` as returned from `bazel_labels.create`.


