<!-- Generated with Stardoc, Do Not Edit! -->
# `create_release` Rule


<a id="create_release"></a>

## create_release

<pre>
create_release(<a href="#create_release-name">name</a>, <a href="#create_release-workflow_name">workflow_name</a>)
</pre>

Declares an executable target that launches a Github Actions release workflow.

This utility expects Github's CLI (`gh`) to be installed. Running this     utility launches a Github Actions workflow that creates a release tag,     generates release notes, creates a release, and creates a PR with an     updated README.md file.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_release-name"></a>name |  The name of the executable target as a <code>string</code>.   |  none |
| <a id="create_release-workflow_name"></a>workflow_name |  The name of the Github Actions workflow.   |  none |


