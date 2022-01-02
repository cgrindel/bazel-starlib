<!-- Generated with Stardoc, Do Not Edit! -->
# Rules and Macros

The rules and macros described below are used to format, test and 
copy Starlark source files.

On this page:

  * [bzlformat_format](#bzlformat_format)
  * [bzlformat_pkg](#bzlformat_pkg)
  * [bzlformat_missing_pkgs](#bzlformat_missing_pkgs)


<a id="#bzlformat_format"></a>

## bzlformat_format

<pre>
bzlformat_format(<a href="#bzlformat_format-name">name</a>, <a href="#bzlformat_format-output_suffix">output_suffix</a>, <a href="#bzlformat_format-srcs">srcs</a>)
</pre>

Formats Starlark source files using Buildifier.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bzlformat_format-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="bzlformat_format-output_suffix"></a>output_suffix |  The suffix added to the formatted output filename.   | String | optional | ".formatted" |
| <a id="bzlformat_format-srcs"></a>srcs |  The Starlark source files to format.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


<a id="#bzlformat_missing_pkgs"></a>

## bzlformat_missing_pkgs

<pre>
bzlformat_missing_pkgs(<a href="#bzlformat_missing_pkgs-name">name</a>, <a href="#bzlformat_missing_pkgs-exclude">exclude</a>)
</pre>

Defines executable targets that find, test and fix any Bazel packages that are missing `bzlformat_pkg` declarations.

Assuming that the name attribute is `bzlformat_missing_pkgs`, the
following targets are defined:

    bzlformat_missing_pkgs_find: Find and report any Bazel packages that
                                 are missing the `bzlformat_pkg`
                                 declaration.
    bzlformat_missing_pkgs_test: Like the find target except it fails if
                                 any missing packages are found. This is
                                 useful to run in CI test runs to ensure
                                 that all is well.
    bzlformat_missing_pkgs_fix: Adds `bzlformat_pkg` declarations to any
                                Bazel packages that are missing the
                                declaration.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bzlformat_missing_pkgs-name"></a>name |  A <code>string</code> that acts as the prefix for the target names that are defined.   |  none |
| <a id="bzlformat_missing_pkgs-exclude"></a>exclude |  A <code>list</code> of packages to exclude from the find, test and fix operations. Each package should be specifed in the format <code>//path/to/package</code>.   |  <code>[]</code> |

**RETURNS**

None.


<a id="#bzlformat_pkg"></a>

## bzlformat_pkg

<pre>
bzlformat_pkg(<a href="#bzlformat_pkg-name">name</a>, <a href="#bzlformat_pkg-srcs">srcs</a>, <a href="#bzlformat_pkg-format_visibility">format_visibility</a>, <a href="#bzlformat_pkg-update_visibility">update_visibility</a>)
</pre>

Defines targets that format, test, and update the specified Starlark source files.

NOTE: Any labels detected in the `srcs` will be ignored.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="bzlformat_pkg-name"></a>name |  The prefix <code>string</code> that is used when creating the targets.   |  <code>"bzlformat"</code> |
| <a id="bzlformat_pkg-srcs"></a>srcs |  Optional. A <code>list</code> of Starlark source files. If no value is provided, any files that match <code>*.bzl</code>, <code>BUILD</code> or <code>BUILD.bazel</code> are used.   |  <code>None</code> |
| <a id="bzlformat_pkg-format_visibility"></a>format_visibility |  Optional. A <code>list</code> of Bazel visibility declarations for the format targets.   |  <code>None</code> |
| <a id="bzlformat_pkg-update_visibility"></a>update_visibility |  Optional. A <code>list</code> of Bazel visibility declarations for the update target.   |  <code>None</code> |

**RETURNS**

None.


