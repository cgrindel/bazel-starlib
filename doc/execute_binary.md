<!-- Generated with Stardoc, Do Not Edit! -->
# `execute_binary` Rule


<a id="#execute_binary"></a>

## execute_binary

<pre>
execute_binary(<a href="#execute_binary-name">name</a>, <a href="#execute_binary-binary">binary</a>, <a href="#execute_binary-data">data</a>, <a href="#execute_binary-file_args">file_args</a>)
</pre>

This rule executes a binary target with the specified arguments. It generates a Bash script that contains a call to the binary with the arguments embedded in the script. This is useful in the following situations:

1. If one wants to embed a call to a binary target with a set of arguments in another rule.

2. If you define a binary target that has a number of dependencies and other configuration values and you do not want to replicate it elsewhere.

Why Not Use A Macro?

You can use a macro which encapsulates the details of the xxx_binary declaration. However, the dependencies for the xxx_binary declaration must be visible anywhere the macro is used.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="execute_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="execute_binary-binary"></a>binary |  The binary to be executed.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="execute_binary-data"></a>data |  Files needed by the binary at runtime.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="execute_binary-file_args"></a>file_args |  A <code>dict</code> mapping of file labels to placeholder names. If any of the specified args for <code>execute_binary</code> are paths to files, add an entry in this attribute where the key is the filename or label referencing the file and the value is a placeholder name. Use the <code>file_placeholder</code> function to create a suitable placeholder string for the args.<br><br>Example<br><br><pre><code> execute_binary(     name = "do_something",     args = [         "--input",         file_placeholder("foo"),         "--input",         file_placeholder("bar"),     ],     file_args = {         # The key is the path          "foo.txt": "foo",         ":bar":  "bar",     }, ) </code></pre>   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: Label -> String</a> | optional | {} |


