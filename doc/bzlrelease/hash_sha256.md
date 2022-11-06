<!-- Generated with Stardoc, Do Not Edit! -->
# `hash_sha256` Rule


<a id="hash_sha256"></a>

## hash_sha256

<pre>
hash_sha256(<a href="#hash_sha256-name">name</a>, <a href="#hash_sha256-src">src</a>)
</pre>

Generates a SHA256 hash for the specified file and writes it to a file with the same name as the label.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="hash_sha256-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="hash_sha256-src"></a>src |  The file whose contents should be hashed.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


