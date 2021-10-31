<!-- Generated with Stardoc, Do Not Edit! -->
# `content_test` Rule


<a id="#content_test"></a>

## content_test

<pre>
content_test(<a href="#content_test-name">name</a>, <a href="#content_test-equals">equals</a>, <a href="#content_test-file">file</a>)
</pre>

Evaluates whether the file contents meet the specified criteria.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="content_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="content_test-equals"></a>equals |  The contents of the file must equal the value of this attribute.   | String | optional | "" |
| <a id="content_test-file"></a>file |  The file whose contents will be evaluated.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


