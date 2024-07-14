<!-- Generated with Stardoc, Do Not Edit! -->
# `release_archive` Rule


<a id="release_archive"></a>

## release_archive

<pre>
release_archive(<a href="#release_archive-name">name</a>, <a href="#release_archive-srcs">srcs</a>, <a href="#release_archive-out">out</a>, <a href="#release_archive-ext">ext</a>)
</pre>

Create a source release archive.

This rule uses `tar` to collect and compress files into an archive file suitable for use as a release artifact. Any permissions on the source files will be preserved.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="release_archive-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="release_archive-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="release_archive-out"></a>out |  The name of the output file.   | String | optional |  `""`  |
| <a id="release_archive-ext"></a>ext |  The extension for the archive.   | String | optional |  `".tar.gz"`  |


