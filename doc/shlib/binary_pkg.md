<!-- Generated with Stardoc, Do Not Edit! -->
# `binary_pkg` Rule


<a id="#binary_pkg"></a>

## binary_pkg

<pre>
binary_pkg(<a href="#binary_pkg-name">name</a>, <a href="#binary_pkg-binary">binary</a>)
</pre>

Generates an executable script that includes the specified binary and all of its runtime dependencies.

This rule was created to mitigate issues with runtime (i.e., runfiles) not being propagated properly in certain situations. For instance, if an `execute_binary` embeds another `execute_binary` and the first `execute_binary` is used in an `sh_test`, the dependencies for second `execute_binary` can be lost.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="binary_pkg-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="binary_pkg-binary"></a>binary |  The binary to be executed.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


