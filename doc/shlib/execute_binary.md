<!-- Generated with Stardoc, Do Not Edit! -->
# `execute_binary` Rule


<a id="execute_binary"></a>

## execute_binary

<pre>
execute_binary(<a href="#execute_binary-name">name</a>, <a href="#execute_binary-data">data</a>, <a href="#execute_binary-arguments">arguments</a>, <a href="#execute_binary-binary">binary</a>, <a href="#execute_binary-execute_in_workspace">execute_in_workspace</a>, <a href="#execute_binary-file_arguments">file_arguments</a>)
</pre>

This rule executes a binary target with the specified arguments. It generates a Bash script that contains a call to the binary with the arguments embedded in the script. This is useful in the following situations:

1. If one wants to embed a call to a binary target with a set of arguments in another rule.

2. If you define a binary target that has a number of dependencies and other configuration values and you do not want to replicate it elsewhere.

Why Not Use A Macro?

You can use a macro which encapsulates the details of the xxx_binary declaration. However, the dependencies for the xxx_binary declaration must be visible anywhere the macro is used.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="execute_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="execute_binary-data"></a>data |  Files needed by the binary at runtime.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="execute_binary-arguments"></a>arguments |  The list of arguments that will be embedded into the resulting executable.<br><br>NOTE: Use this attribute instead of `args`. The `args` attribute is not processed for file arguments and is not preserved in the resulting script.   | List of strings | optional |  `[]`  |
| <a id="execute_binary-binary"></a>binary |  The binary to be executed.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="execute_binary-execute_in_workspace"></a>execute_in_workspace |  If true, the binary will be executed in the Bazel workspace (i.e., source) directory.   | Boolean | optional |  `False`  |
| <a id="execute_binary-file_arguments"></a>file_arguments |  A `dict` mapping of file labels to placeholder names. If any of the specified `arguments` for `execute_binary` are paths to files, add an entry in this attribute where the key is the filename or label referencing the file and the value is a placeholder name. Use the `file_placeholder` function to create a suitable placeholder string for the arguments.<br><br>Example<br><br><pre><code>execute_binary(&#10;    name = "do_something",&#10;    arguments = [&#10;        "--input",&#10;        file_placeholder("foo"),&#10;        "--input",&#10;        file_placeholder("bar"),&#10;    ],&#10;    file_arguments = {&#10;        # The key is the path&#10;        "foo.txt": "foo",&#10;        ":bar":  "bar",&#10;    },&#10;)</code></pre>   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |


