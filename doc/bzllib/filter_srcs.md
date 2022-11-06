<!-- Generated with Stardoc, Do Not Edit! -->
# `filter_srcs` Rule


<a id="filter_srcs"></a>

## filter_srcs

<pre>
filter_srcs(<a href="#filter_srcs-name">name</a>, <a href="#filter_srcs-expected_count">expected_count</a>, <a href="#filter_srcs-filename_ends_with">filename_ends_with</a>, <a href="#filter_srcs-srcs">srcs</a>)
</pre>

Filters the provided inputs using the specified criteria.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="filter_srcs-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="filter_srcs-expected_count"></a>expected_count |  The expected number of results.   | Integer | optional | <code>-1</code> |
| <a id="filter_srcs-filename_ends_with"></a>filename_ends_with |  The suffix of the path will be compared to this value.   | String | optional | <code>""</code> |
| <a id="filter_srcs-srcs"></a>srcs |  The inputs that will be evaluated by the filter.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |


